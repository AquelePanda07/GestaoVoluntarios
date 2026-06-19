import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voluntarios/services/volunteer_service.dart';

class VolunteerListPage extends StatefulWidget {
  const VolunteerListPage({super.key});

  @override
  State<VolunteerListPage> createState() => _VolunteerListPageState();
}

class _VolunteerListPageState extends State<VolunteerListPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lotacaoController = TextEditingController();
  final _tempoController = TextEditingController();
  final _photoController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final VolunteerService _service = VolunteerService();
  DateTime? _selectedEndDate;
  List<Volunteer> _volunteers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    setState(() => _isLoading = true);
    try {
      final volunteers = await _service.fetchVolunteers();
      if (!mounted) {
        return;
      }
      setState(() {
        _volunteers = volunteers;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar voluntários: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lotacaoController.dispose();
    _tempoController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) {
      return;
    }

    _photoController.text = picked.path;
  }

  Future<void> _pickContractEndDate() async {
    final now = DateTime.now();
    final initialDate = _selectedEndDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null) {
      return;
    }

    _selectedEndDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );
    _tempoController.text = _formatDateForStorage(_selectedEndDate!);
    setState(() {});
  }

  DateTime? _parseStoredDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final iso = DateTime.tryParse(normalized);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    final parts = normalized.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  String _formatDateForStorage(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatDateForDisplay(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _buildContractStatus(String tempoValue) {
    final endDate = _parseStoredDate(tempoValue);
    if (endDate == null) {
      return 'Data invalida';
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysLeft = endDate.difference(todayOnly).inDays;

    if (daysLeft > 0) {
      return 'Faltam $daysLeft dias';
    }
    if (daysLeft == 0) {
      return 'Contrato termina hoje';
    }
    return 'Contrato encerrado ha ${daysLeft.abs()} dias';
  }

  String _buildContractEndDateLabel(String tempoValue) {
    final endDate = _parseStoredDate(tempoValue);
    if (endDate == null) {
      return 'Data invalida';
    }
    return _formatDateForDisplay(endDate);
  }

  Color _contractStatusColor(String tempoValue) {
    final endDate = _parseStoredDate(tempoValue);
    if (endDate == null) return Colors.grey;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysLeft = endDate.difference(todayOnly).inDays;

    if (daysLeft > 30) return const Color(0xFF2E7D32);
    if (daysLeft > 0) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  Widget _buildVolunteerImage(String imagePath) {
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageFallback(),
      );
    }

    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade300,
      child: const Icon(Icons.person, size: 30),
    );
  }

  Future<void> _addVolunteer() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _service.createVolunteer(
        nome: _nameController.text.trim(),
        lotacao: _lotacaoController.text.trim(),
        tempo: _tempoController.text.trim(),
        imagem: _photoController.text.trim().isEmpty
            ? 'https://via.placeholder.com/150'
            : _photoController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível criar o voluntário.')),
        );
        return;
      }

      _nameController.clear();
      _lotacaoController.clear();
      _tempoController.clear();
      _photoController.clear();
      _selectedEndDate = null;

      Navigator.of(context).pop();
      await _loadVolunteers();
    }
  }

  void _showAddVolunteerDialog() {
    _nameController.clear();
    _lotacaoController.clear();
    _tempoController.clear();
    _photoController.clear();
    _selectedEndDate = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar novo voluntário'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome do voluntário';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lotacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Lotação',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a lotação';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tempoController,
                    readOnly: true,
                    onTap: _pickContractEndDate,
                    decoration: InputDecoration(
                      labelText: 'Fim do contrato',
                      hintText: 'Selecione uma data',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _pickContractEndDate,
                        tooltip: 'Selecionar data',
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a data final do contrato';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _photoController,
                    decoration: InputDecoration(
                      labelText: 'Foto (opcional)',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _pickImageFromGallery,
                        tooltip: 'Selecionar da galeria',
                        icon: const Icon(Icons.photo_library),
                      ),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _addVolunteer,
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  void _editVolunteer(int index) {
    final volunteer = _volunteers[index];
    _nameController.text = volunteer.nome;
    _lotacaoController.text = volunteer.lotacao;
    _tempoController.text = volunteer.tempo;
    _selectedEndDate = _parseStoredDate(volunteer.tempo);
    _photoController.text = volunteer.imagem;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar voluntário'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome do voluntário';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lotacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Lotação',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a lotação';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tempoController,
                    readOnly: true,
                    onTap: _pickContractEndDate,
                    decoration: InputDecoration(
                      labelText: 'Fim do contrato',
                      hintText: 'Selecione uma data',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _pickContractEndDate,
                        tooltip: 'Selecionar data',
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a data final do contrato';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _photoController,
                    decoration: InputDecoration(
                      labelText: 'Foto (opcional)',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _pickImageFromGallery,
                        tooltip: 'Selecionar da galeria',
                        icon: const Icon(Icons.photo_library),
                      ),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final success = await _service.updateVolunteer(
                    id: volunteer.id,
                    nome: _nameController.text.trim(),
                    lotacao: _lotacaoController.text.trim(),
                    tempo: _tempoController.text.trim(),
                    imagem: _photoController.text.trim().isEmpty
                        ? 'https://via.placeholder.com/150'
                        : _photoController.text.trim(),
                  );

                  if (!context.mounted) {
                    return;
                  }

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Não foi possível atualizar o voluntário.',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  await _loadVolunteers();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteVolunteer(int index) {
    final volunteer = _volunteers[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir voluntário'),
          content: Text('Tem certeza que deseja excluir ${volunteer.nome}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _service.deleteVolunteer(volunteer.id);
                if (!context.mounted) {
                  return;
                }

                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível excluir o voluntário.'),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voluntário excluído com sucesso!'),
                  ),
                );
                await _loadVolunteers();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(title: const Text('Voluntários')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              'Lista de Funcionários',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadVolunteers,
                      child: ListView.separated(
                        itemCount: _volunteers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final volunteer = _volunteers[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildVolunteerImage(
                                      volunteer.imagem,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          volunteer.nome,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1565C0),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 14,
                                                color: Color(0xFF1565C0)),
                                            const SizedBox(width: 4),
                                            Text(volunteer.lotacao,
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 14,
                                                color: Color(0xFF1565C0)),
                                            const SizedBox(width: 4),
                                            Text(
                                              _buildContractEndDateLabel(
                                                  volunteer.tempo),
                                              style: const TextStyle(
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _contractStatusColor(
                                                volunteer.tempo),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _buildContractStatus(
                                                volunteer.tempo),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editVolunteer(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _deleteVolunteer(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Deslogar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        ),
      ),
    ],
  ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVolunteerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
