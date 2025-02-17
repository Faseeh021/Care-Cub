import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController childNameController;
  late TextEditingController childDobController;
  File? pickedImage;
  bool isEditing = false;
  bool isUpdating = false;
  DateTime? selectedChildDob;
  String? childId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    childNameController = TextEditingController();
    childDobController = TextEditingController();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream() {
    final String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return firestore.collection('users').doc(uid).snapshots();
    }
    throw Exception('User not logged in');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChildDataStream() {
    final String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return firestore
          .collection('users')
          .doc(uid)
          .collection('babyProfiles')
          .snapshots();
    }
    throw Exception('User not logged in');
  }

  Future<void> updateProfile() async {
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => isUpdating = true);

    try {
      await firestore.collection('users').doc(user.uid).update({
        'name': nameController.text,
        'phone': phoneController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (childId != null) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('babyProfiles')
            .doc(childId)
            .update({
          'name': childNameController.text,
          'dateOfBirth': selectedChildDob,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile and child details updated successfully!')),
      );

      setState(() {
        isEditing = false;
        pickedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> selectChildDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedChildDob ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedChildDob = picked;
        childDobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void ConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Update'),
        content: Text('Are you sure you want to update your profile and child details?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              updateProfile();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await auth.signOut();
    await googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        title: Text('User Profile', style: TextStyle(color: Color(0xFFFFEBFF))),
        backgroundColor: Colors.deepOrange.shade500,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                ConfirmationDialog();
              } else {
                setState(() => isEditing = true);
              }
            },
          )
        ],
        centerTitle: true,
      ),
      body: isUpdating
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() ?? {};
          if (!isEditing) {
            nameController.text = data['name'] ?? '';
            phoneController.text = data['phone'] ?? '';
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                // User Profile Section
                GestureDetector(
                  child: Center(
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: pickedImage != null
                          ? FileImage(pickedImage!)
                          : (data['photoUrl'] != null && data['photoUrl'] is String
                          ? NetworkImage(data['photoUrl'])
                          : null),
                      child: pickedImage == null && data['photoUrl'] == null
                          ? Text(
                        data['name']?.isNotEmpty == true
                            ? data['name'][0].toUpperCase()
                            : '?',
                        style: TextStyle(fontSize: 40),
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  enabled: isEditing,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: data['email'] ?? ''),
                  decoration: InputDecoration(labelText: 'Email'),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  enabled: isEditing,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),

                // Child Details Section
                Text(
                  'Child Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade500,
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: getChildDataStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                    final children = snapshot.data!.docs;
                    if (children.isEmpty) {
                      return Text('No child data found.');
                    }

                    final childData = children.first.data();
                    childId = children.first.id;
                    final name = childData['name'] ?? 'No Name';
                    final dob = childData['dateOfBirth']?.toDate();

                    if (!isEditing) {
                      childNameController.text = name;
                      selectedChildDob = dob;
                      childDobController.text = dob != null
                          ? "${dob.day}/${dob.month}/${dob.year}"
                          : '';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: childNameController,
                          decoration: InputDecoration(labelText: 'Child Name'),
                          enabled: isEditing,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: childDobController,
                          decoration: InputDecoration(labelText: 'Date of Birth'),
                          readOnly: true,
                          onTap: () => selectChildDob(context),
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),

                // Logout Button
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade500,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Logout', style: TextStyle(color: Color(0xFFFFEBFF))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}