import 'package:flutter/material.dart';

class ExamType {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  final String preparation;
  final int durationMinutes;

  const ExamType({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.preparation,
    required this.durationMinutes,
  });
}

enum AppointmentStatus { agendado, confirmado, concluido, cancelado }

class Appointment {
  final String id;
  final ExamType exam;
  final DateTime dateTime;
  final String unit;
  final AppointmentStatus status;
  final String doctor;

  const Appointment({
    required this.id,
    required this.exam,
    required this.dateTime,
    required this.unit,
    required this.status,
    required this.doctor,
  });
}

class ExamResult {
  final String id;
  final String examName;
  final DateTime date;
  final String unit;
  final bool isNew;
  final String fileSize;

  const ExamResult({
    required this.id,
    required this.examName,
    required this.date,
    required this.unit,
    required this.isNew,
    required this.fileSize,
  });
}

class Unit {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String hours;
  final double distanceKm;

  const Unit({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.distanceKm,
  });
}

class UserProfile {
  final String name;
  final String cpf;
  final String email;
  final String phone;
  final DateTime birthDate;
  final String insurance;

  const UserProfile({
    required this.name,
    required this.cpf,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.insurance,
  });
}
