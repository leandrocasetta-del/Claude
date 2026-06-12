import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static const Duration _timeout = Duration(seconds: 8);

  Future<Map<String, dynamic>> _getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) {
        throw ApiException('Status ${res.statusCode} em $path');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on SocketException {
      throw ApiException('Backend offline. Rode "npm start" em mock_backend/.');
    }
  }

  Future<List<dynamic>> _getList(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) {
        throw ApiException('Status ${res.statusCode} em $path');
      }
      return jsonDecode(res.body) as List<dynamic>;
    } on SocketException {
      throw ApiException('Backend offline. Rode "npm start" em mock_backend/.');
    }
  }

  Future<UserProfile> fetchUser() async {
    final j = await _getJson('/api/me');
    return UserProfile(
      name: j['name'],
      cpf: j['cpf'],
      email: j['email'],
      phone: j['phone'],
      birthDate: DateTime.parse(j['birthDate']),
      insurance: j['insurance'],
    );
  }

  Future<List<ExamType>> fetchExamTypes() async {
    final list = await _getList('/api/exam-types');
    return list.map((j) => _parseExam(j as Map<String, dynamic>)).toList();
  }

  Future<List<Appointment>> fetchAppointments() async {
    final list = await _getList('/api/appointments');
    final exams = await fetchExamTypes();
    final examMap = {for (final e in exams) e.id: e};
    final now = DateTime.now();
    return list.map((raw) {
      final j = raw as Map<String, dynamic>;
      final exam = examMap[j['examId']] ?? exams.first;
      final dt = now.add(
        Duration(
          days: (j['dateTimeOffsetDays'] as num).toInt(),
          hours: (j['dateTimeOffsetHours'] as num).toInt(),
        ),
      );
      return Appointment(
        id: j['id'],
        exam: exam,
        dateTime: dt,
        unit: j['unit'],
        status: _parseStatus(j['status']),
        doctor: j['doctor'],
      );
    }).toList();
  }

  Future<void> createAppointment({
    required String examId,
    required String unit,
    required DateTime dateTime,
  }) async {
    final uri = Uri.parse('$baseUrl/api/appointments');
    final now = DateTime.now();
    final diff = dateTime.difference(now);
    final offsetDays = diff.inDays;
    final offsetHours = diff.inHours - (offsetDays * 24);
    final body = {
      'id': 'a${DateTime.now().millisecondsSinceEpoch}',
      'examId': examId,
      'dateTimeOffsetDays': offsetDays,
      'dateTimeOffsetHours': offsetHours,
      'unit': unit,
      'status': 'agendado',
      'doctor': 'Auto-agendado pelo app',
    };
    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (res.statusCode != 201 && res.statusCode != 200) {
        throw ApiException('Erro ao criar agendamento: ${res.statusCode}');
      }
    } on SocketException {
      throw ApiException('Backend offline. Rode "npm start" em mock_backend/.');
    }
  }

  Future<void> cancelAppointment(String id) async {
    final uri = Uri.parse('$baseUrl/api/appointments/$id');
    try {
      final res = await http.delete(uri).timeout(_timeout);
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw ApiException('Erro ao cancelar: ${res.statusCode}');
      }
    } on SocketException {
      throw ApiException('Backend offline.');
    }
  }

  Future<List<ExamResult>> fetchResults() async {
    final list = await _getList('/api/results');
    final now = DateTime.now();
    return list.map((raw) {
      final j = raw as Map<String, dynamic>;
      return ExamResult(
        id: j['id'],
        examName: j['examName'],
        date: now.add(Duration(days: (j['dateOffsetDays'] as num).toInt())),
        unit: j['unit'],
        isNew: j['isNew'] as bool,
        fileSize: j['fileSize'],
      );
    }).toList();
  }

  Future<List<Unit>> fetchUnits() async {
    final list = await _getList('/api/units');
    return list.map((raw) {
      final j = raw as Map<String, dynamic>;
      return Unit(
        id: j['id'],
        name: j['name'],
        address: j['address'],
        phone: j['phone'],
        hours: j['hours'],
        distanceKm: (j['distanceKm'] as num).toDouble(),
      );
    }).toList();
  }

  Future<bool> login(String cpf, String password) async {
    final j = await _getJson('/api/auth');
    return j['validCpf'] == cpf && j['validPassword'] == password;
  }

  ExamType _parseExam(Map<String, dynamic> j) {
    return ExamType(
      id: j['id'],
      name: j['name'],
      category: j['category'],
      icon: _iconFromName(j['icon']),
      preparation: j['preparation'],
      durationMinutes: (j['durationMinutes'] as num).toInt(),
    );
  }

  AppointmentStatus _parseStatus(String s) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => AppointmentStatus.agendado,
    );
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'biotech':
        return Icons.biotech_outlined;
      case 'monitor_heart':
        return Icons.monitor_heart_outlined;
      case 'image':
        return Icons.image_outlined;
      case 'bloodtype':
        return Icons.bloodtype_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      case 'directions_run':
        return Icons.directions_run_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }
}
