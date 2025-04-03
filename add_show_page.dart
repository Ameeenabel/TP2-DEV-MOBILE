import 'dart:io';
import 'package:android/screens/home.page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UpdateShowPage extends StatefulWidget {
  final Map<String, dynamic> showData;

  const UpdateShowPage({Key? key, required this.showData, required Show show}) : super(key: key);

  @override
  _UpdateShowPageState createState() => _UpdateShowPageState();
}

class _UpdateShowPageState extends State<UpdateShowPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.showData['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.showData['description'] ?? '');
    _selectedCategory = widget.showData['category'] ?? 'movie';
    _currentImageUrl = widget.showData['image'];
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _currentImageUrl = null; // Reset URL when new image is selected
        });
      }
    } catch (e) {
      _showError("Erreur lors de la sélection de l'image");
    }
  }

  Future<void> _updateShow() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showError("Veuillez remplir tous les champs obligatoires");
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/shows/${widget.showData['id']}');
      final request = http.MultipartRequest('PUT', uri);

      // Add text fields
      request.fields.addAll({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
      });

      // Add image file if selected
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _showSuccess("Show mis à jour avec succès!");
        Navigator.pop(context, true); // Return with success flag
      } else {
        throw Exception('Échec de la mise à jour: ${response.statusCode}\n$responseBody');
      }
    } catch (e) {
      _showError("Erreur lors de la mise à jour: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le Show"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isUploading ? null : _updateShow,
            tooltip: "Enregistrer les modifications",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Titre*",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? "Ce champ est obligatoire" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description*",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? "Ce champ est obligatoire" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: const [
                    DropdownMenuItem(value: "movie", child: Text("Film")),
                    DropdownMenuItem(value: "anime", child: Text("Anime")),
                    DropdownMenuItem(value: "serie", child: Text("Série")),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                  decoration: const InputDecoration(
                    labelText: "Catégorie",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Image display section
                if (_currentImageUrl != null || _imageFile != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Image actuelle", style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          _imageFile != null
                              ? Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
                              : _buildNetworkImage(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Image selection buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Galerie"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Appareil photo"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Submit button
                ElevatedButton(
                  onPressed: _isUploading ? null : _updateShow,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ENREGISTRER LES MODIFICATIONS"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    final imageUrl = _currentImageUrl!.startsWith('http')
        ? _currentImageUrl!
        : '${ApiConfig.baseUrl}$_currentImageUrl';

    return Image.network(
      imageUrl,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
