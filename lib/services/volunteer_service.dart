import 'dart:convert';

import 'package:http/http.dart' as http;

class Volunteer {
  final int id;
  final String nome;
  final String lotacao;
  final String tempo;
  final String imagem;

  const Volunteer({
    required this.id,
    required this.nome,
    required this.lotacao,
    required this.tempo,
    required this.imagem,
  });

  factory Volunteer.fromMap(Map<String, dynamic> map) {
    return Volunteer(
      id: int.tryParse(map['id'].toString()) ?? 0,
      nome: map['nome']?.toString() ?? '',
      lotacao: map['lotacao']?.toString() ?? '',
      tempo: map['tempo']?.toString() ?? '',
      imagem: map['imagem']?.toString() ?? '',
    );
  }
}

class VolunteerService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/voluntarios_api',
  );

  Uri _endpoint(String path) => Uri.parse('$_baseUrl/$path');

  Future<List<Volunteer>> fetchVolunteers() async {
    final response = await http.get(_endpoint('volunteers_list.php')).timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar voluntários');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'Falha ao carregar');
    }

    final list = (data['voluntarios'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Volunteer.fromMap)
        .toList();

    return list;
  }

  Future<bool> createVolunteer({
    required String nome,
    required String lotacao,
    required String tempo,
    required String imagem,
  }) async {
    final response = await http
        .post(
          _endpoint('volunteer_create.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': nome,
            'lotacao': lotacao,
            'tempo': tempo,
            'imagem': imagem,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['success'] == true;
  }

  Future<bool> updateVolunteer({
    required int id,
    required String nome,
    required String lotacao,
    required String tempo,
    required String imagem,
  }) async {
    final response = await http
        .post(
          _endpoint('volunteer_update.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'nome': nome,
            'lotacao': lotacao,
            'tempo': tempo,
            'imagem': imagem,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['success'] == true;
  }

  Future<bool> deleteVolunteer(int id) async {
    final response = await http
        .post(
          _endpoint('volunteer_delete.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['success'] == true;
  }
}
