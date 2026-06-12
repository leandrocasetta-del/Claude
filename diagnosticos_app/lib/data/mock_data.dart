import 'package:flutter/material.dart';
import '../models/models.dart';

class MockData {
  static final UserProfile currentUser = UserProfile(
    name: 'Leandro Casetta',
    cpf: '123.456.789-00',
    email: 'leandro.casetta@gmail.com',
    phone: '(11) 99999-9999',
    birthDate: DateTime(1990, 5, 14),
    insurance: 'Particular',
  );

  static const List<ExamType> examTypes = [
    ExamType(
      id: 'e1',
      name: 'Ressonancia Magnetica',
      category: 'Imagem',
      icon: Icons.medical_services_outlined,
      preparation: 'Jejum de 4 horas. Levar exames anteriores.',
      durationMinutes: 45,
    ),
    ExamType(
      id: 'e2',
      name: 'Tomografia Computadorizada',
      category: 'Imagem',
      icon: Icons.biotech_outlined,
      preparation: 'Jejum de 6 horas para exames com contraste.',
      durationMinutes: 30,
    ),
    ExamType(
      id: 'e3',
      name: 'Ultrassonografia',
      category: 'Imagem',
      icon: Icons.monitor_heart_outlined,
      preparation: 'Bexiga cheia para US pelvico.',
      durationMinutes: 20,
    ),
    ExamType(
      id: 'e4',
      name: 'Raio-X',
      category: 'Imagem',
      icon: Icons.image_outlined,
      preparation: 'Sem preparo especifico.',
      durationMinutes: 15,
    ),
    ExamType(
      id: 'e5',
      name: 'Coleta de Sangue',
      category: 'Laboratorio',
      icon: Icons.bloodtype_outlined,
      preparation: 'Jejum de 8 a 12 horas.',
      durationMinutes: 10,
    ),
    ExamType(
      id: 'e6',
      name: 'Eletrocardiograma',
      category: 'Cardiologia',
      icon: Icons.favorite_outline,
      preparation: 'Evitar cafeina nas 4 horas anteriores.',
      durationMinutes: 15,
    ),
    ExamType(
      id: 'e7',
      name: 'Ecocardiograma',
      category: 'Cardiologia',
      icon: Icons.favorite_outline,
      preparation: 'Sem preparo especifico.',
      durationMinutes: 30,
    ),
    ExamType(
      id: 'e8',
      name: 'Teste Ergometrico',
      category: 'Cardiologia',
      icon: Icons.directions_run_outlined,
      preparation: 'Levar roupa e tenis confortaveis.',
      durationMinutes: 60,
    ),
  ];

  static final List<Appointment> appointments = [
    Appointment(
      id: 'a1',
      exam: examTypes[0],
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 2)),
      unit: 'Unidade Paraiso',
      status: AppointmentStatus.confirmado,
      doctor: 'Dr. Marcelo Andrade',
    ),
    Appointment(
      id: 'a2',
      exam: examTypes[4],
      dateTime: DateTime.now().add(const Duration(days: 7)),
      unit: 'Unidade Cidade Jardim',
      status: AppointmentStatus.agendado,
      doctor: 'Solicitante: Dra. Carla Mendes',
    ),
    Appointment(
      id: 'a3',
      exam: examTypes[5],
      dateTime: DateTime.now().subtract(const Duration(days: 15)),
      unit: 'Unidade Paraiso',
      status: AppointmentStatus.concluido,
      doctor: 'Dr. Roberto Lima',
    ),
  ];

  static final List<ExamResult> results = [
    ExamResult(
      id: 'r1',
      examName: 'Eletrocardiograma',
      date: DateTime.now().subtract(const Duration(days: 15)),
      unit: 'Unidade Paraiso',
      isNew: true,
      fileSize: '1.2 MB',
    ),
    ExamResult(
      id: 'r2',
      examName: 'Hemograma Completo',
      date: DateTime.now().subtract(const Duration(days: 45)),
      unit: 'Unidade Cidade Jardim',
      isNew: false,
      fileSize: '340 KB',
    ),
    ExamResult(
      id: 'r3',
      examName: 'Ultrassonografia Abdominal',
      date: DateTime.now().subtract(const Duration(days: 90)),
      unit: 'Unidade Paraiso',
      isNew: false,
      fileSize: '4.8 MB',
    ),
    ExamResult(
      id: 'r4',
      examName: 'Raio-X de Torax',
      date: DateTime.now().subtract(const Duration(days: 120)),
      unit: 'Unidade Paraiso',
      isNew: false,
      fileSize: '2.1 MB',
    ),
  ];

  static const List<Unit> units = [
    Unit(
      id: 'u1',
      name: 'Unidade Paraiso',
      address: 'Rua Desembargador Eliseu Guilherme, 147 - Paraiso, Sao Paulo',
      phone: '(11) 3053-6611',
      hours: 'Seg a Sex: 6h-22h | Sab: 7h-18h',
      distanceKm: 2.4,
    ),
    Unit(
      id: 'u2',
      name: 'Unidade Cidade Jardim',
      address: 'Av. Magalhaes de Castro, 4800 - Cidade Jardim, Sao Paulo',
      phone: '(11) 3094-1500',
      hours: 'Seg a Sex: 7h-20h | Sab: 8h-14h',
      distanceKm: 5.8,
    ),
    Unit(
      id: 'u3',
      name: 'Unidade Itaim',
      address: 'Rua Joaquim Floriano, 466 - Itaim Bibi, Sao Paulo',
      phone: '(11) 3078-9090',
      hours: 'Seg a Sex: 7h-19h',
      distanceKm: 7.1,
    ),
  ];

  static const List<String> categories = [
    'Imagem',
    'Laboratorio',
    'Cardiologia',
  ];
}
