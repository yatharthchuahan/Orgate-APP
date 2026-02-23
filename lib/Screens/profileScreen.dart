import 'package:flutter/material.dart';
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/Widgets/appbar.dart';
import 'package:orangtre/Widgets/drawer.dart';
import 'package:orangtre/model/login_response.dart';
import 'package:orangtre/utils/format_login_time.dart';
import 'package:orangtre/utils/format_gender.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:orangtre/utils/convert_base64.dart';
import 'package:orangtre/Services/uploadProfilePic.dart';
import 'package:orangtre/Widgets/customLoader.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final ImagePicker _picker = ImagePicker();

  Future<LoginResponse?> _loadLoginData() async {
    return await LoginStorage.getLoginResponse();
  }

  String _getFullImageUrl(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) return '';
    // If fileUrl already starts with http, return as is
    if (fileUrl.startsWith('http')) return fileUrl;
    // Otherwise, combine with base URL
    return 'https://demoapi.wavelift.in/api/$fileUrl';
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Profile',
      drawer: const OrangtreDrawer(),
      body: FutureBuilder<LoginResponse?>(
        future: _loadLoginData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No user data found."));
          } else {
            final user = snapshot.data!.userData;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Header
                  _buildProfileHeader(
                    '${user.firstName} ${user.lastName}',
                    user.userTypeName,
                    _getFullImageUrl(user.fileURL),
                  ),
                  const SizedBox(height: 30),

                  // User Information Card
                  _buildUserInfoCard(
                   '${user.firstName} ${user.lastName}',
                    user.email ?? 'N/A',
                    formatGender(user.gender),
                    user.empCode
                  ),
                  const SizedBox(height: 20),

                  // Status Card
                  _buildStatusCard(
                    formatLoginTime(user.loginTimeUser)
                  ),
                  const SizedBox(height: 30),

                  // Edit Profile Button
                  _buildEditButton(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(String fullname, String status, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: imageUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF2C3E50),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2C3E50),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF2C3E50),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // User Name
          Text(
            fullname,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // User Role/Title
          Text(
            status,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(
    String fullname,
    String email,
    String gender,
    String empcode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),

          _buildInfoRow(Icons.person, 'Full Name', fullname),
          const SizedBox(height: 15),

          _buildInfoRow(Icons.email, 'Email Address', email),
          const SizedBox(height: 15),

          _buildInfoRow(Icons.wc, 'Gender', gender),
          const SizedBox(height: 15),

          _buildInfoRow(Icons.badge, 'Employee ID', empcode),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String lastlogin,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
            Icons.laptop_mac_rounded,
            'Last Login',
            '$lastlogin',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2C3E50), size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showImageSourceDialog();
        },
        icon: const Icon(Icons.upload_rounded, size: 20),
        label: const Text(
          'Upload Profile Picture',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C3E50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Title
                const Text(
                  'Choose Image Source',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Camera Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF2C3E50),
                      size: 30,
                    ),
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Take a new photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                
                // Gallery Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF2C3E50),
                      size: 30,
                    ),
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: LoaderOverlay()),
        );

        // Convert image to File
        File imageFile = File(image.path);

        // Convert to base64
        String base64Image = await fileToBase64(imageFile);

        // Get file size
        int sizeInBytes = getBase64FileSize(base64Image);
        String readableSize = formatFileSize(sizeInBytes);

        print('📸 Image captured/selected');
        print('📏 Image size: $readableSize');

        // Upload to API
        await _uploadProfilePicture(base64Image);

        // Close loading dialog
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('❌ Error picking image: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(String base64Image) async {
    try {
      final uploadService = Uploadprofilepic();
      await uploadService.uploadprofilepic(
        base64Image: base64Image,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile picture uploaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );

        // Refresh the screen to show new profile picture
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
