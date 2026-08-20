import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  final _picker = ImagePicker();

  Future<String?> pickFromCamera() => _pickAndSave(ImageSource.camera);
  Future<String?> pickFromGallery() => _pickAndSave(ImageSource.gallery);
      Future<String?> _pickAndSave(ImageSource source) async{
    final XFile? picked = await _picker.pickImage(source: source,maxWidth: 800,imageQuality: 85);
    if(picked == null) return null;
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');
    return savedImage.path;

      }
}