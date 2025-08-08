import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  // Galeri veya kameradan resim seç
  static Future<XFile?> pickImage(
      {ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Resim seçme hatası: $e');
      return null;
    }
  }

  // Firebase Storage'a resim yükle
  static Future<String?> uploadImage(XFile imageFile, String folder) async {
    try {
      // Dosya adını oluştur
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';

      // Firebase Storage referansı
      Reference ref = _storage.ref().child(folder).child(fileName);

      // Dosyayı yükle
      UploadTask uploadTask = ref.putFile(File(imageFile.path));

      // Yükleme tamamlanana kadar bekle
      TaskSnapshot snapshot = await uploadTask;

      // Download URL'i al
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Resim yükleme hatası: $e');
      return null;
    }
  }

  // Pet resmi yükle
  static Future<String?> uploadPetImage(XFile imageFile, String petId) async {
    return await uploadImage(imageFile, 'pets/$petId');
  }

  // Note resmi yükle
  static Future<String?> uploadNoteImage(XFile imageFile, String noteId) async {
    return await uploadImage(imageFile, 'notes/$noteId');
  }

  // Firebase Storage'dan resim sil
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Resim silme hatası: $e');
      return false;
    }
  }

  // Resim seçme ve yükleme helper metodu
  static Future<String?> pickAndUploadImage({
    required String folder,
    ImageSource source = ImageSource.gallery,
  }) async {
    // Resim seç
    XFile? imageFile = await pickImage(source: source);
    if (imageFile == null) return null;

    // Resmi yükle
    String? imageUrl = await uploadImage(imageFile, folder);
    return imageUrl;
  }

  // Galeri ve kamera seçim dialog'u için helper
  static Future<String?> showImagePickerDialog({
    required String folder,
    required Function(ImageSource) onSourceSelected,
  }) async {
    // Bu method UI component'inde kullanılacak
    // Burada sadece logic'i sağlıyoruz
    return null;
  }
}
