import 'package:flutter/material.dart';
import 'package:orangtre/StoredData/UserHelper.dart';
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/utils/perform_logout.dart';

class OrangtreDrawer extends StatefulWidget {
  const OrangtreDrawer({Key? key}) : super(key: key);

  @override
  State<OrangtreDrawer> createState() => _OrangtreDrawerState();
}

class _OrangtreDrawerState extends State<OrangtreDrawer> {
  String userName = 'User Name';
  String userEmail = 'user@orangtre.com';
  String? userImageUrl;
  String userRole = '';
  bool isAdmin = false;
  String userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final fullName = await UserHelper.getFullName();
    final email = await UserHelper.getEmail();
    final profileUrl = await UserHelper.getFullProfilePictureURL();
    final role = await UserHelper.getRole();
    
    // Check if user is admin
    final loginResponse = await LoginStorage.getLoginResponse();
    final fetchedUserType = loginResponse?.userData.userType ?? '';

    setState(() {
      userName = fullName.isNotEmpty ? fullName : 'User Name';
      userEmail = email.isNotEmpty ? email : 'N/A';
      userImageUrl = profileUrl.isNotEmpty ? profileUrl : null;
      userRole = role;
      userType = fetchedUserType;
      isAdmin = fetchedUserType == 'A' || fetchedUserType == 'S';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: userImageUrl != null && userImageUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              userImageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF2C3E50),
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF2C3E50),
                          ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.manage_search_rounded,
                  title: 'Manage Stock',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/manageStock');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Inventory',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/inventory');
                  },
                ),
                // Show Sales menu only for admin and retailer users
                if (userType == 'A' || userType == 'S' || userType == 'R')
                  _buildDrawerItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Sales',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/sales');
                    },
                  ),
                // Show Account menu only for admin users
                if (isAdmin)
                  _buildDrawerItem(
                    context,
                    icon: Icons.manage_accounts_rounded,
                    title: 'Account',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/account');
                    },
                  ),

                _buildDrawerItem(
                  context,
                  icon: Icons.person_2_rounded,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),

                const Divider(
                  height: 20,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),

                const Text(
                  "Version 1.0",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? badge,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2C3E50), size: 26),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: const Color(0xFF2C3E50).withOpacity(0.1),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}
