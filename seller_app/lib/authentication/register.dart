import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_app/mainScreens/home_screen.dart';
import 'package:seller_app/widgets/custom_text_field.dart';
import 'package:seller_app/widgets/error_dialog.dart';
import 'package:seller_app/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as f_storage;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placemarks;

  String completeAddress = "";

  String sellerImageUrl = "";

  late bool serviceEnabled;

  late LocationPermission permission;

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please select an image.",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          // start uploading image
          showDialog(
              context: context,
              builder: (c) {
                return const LoadingDialog(
                  message: "Registering Account",
                );
              });

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();

          f_storage.Reference reference = f_storage.FirebaseStorage.instance
              .ref()
              .child("Sellers")
              .child(fileName);
          f_storage.UploadTask uploadTask =
              reference.putFile(File(imageXFile!.path));
          f_storage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() => {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;

            authenticateSellerAndSignUp();
          });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return const ErrorDialog(
                  message: "All fields must be entered for registration",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Passwords do not match.",
              );
            });
      }
    }
  }

  getCurrentLocation() async {
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;
    placemarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);
    Placemark pmark = placemarks!.first;
    completeAddress =
        '${pmark.subThoroughfare} ${pmark.thoroughfare}, ${pmark.subLocality}, ${pmark.locality}, ${pmark.subAdministrativeArea}, ${pmark.administrativeArea} ${pmark.postalCode}, ${pmark.country}';
    locationController.text = completeAddress;
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  void authenticateSellerAndSignUp() async {
    User? currentUser;
    await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim()).then((auth) {
          currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(context: context, builder: (c) {
        return ErrorDialog(message: error.message.toString(),);
      });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        Navigator.push(context, newRoute);
      });
    }
  }

  Future<void> saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvatarUrl": sellerImageUrl,
      "sellerPhone": phoneController.text.trim(),
      "sellerAddress": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    // save to device storage
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
    await sharedPreferences!.setString("email", currentUser.email.toString());

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            InkWell(
              onTap: () {
                _getImage();
              },
              child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.20,
                  backgroundColor: Colors.white,
                  backgroundImage: imageXFile == null
                      ? null
                      : FileImage(File(
                          imageXFile!.path,
                        )),
                  child: imageXFile == null
                      ? Icon(
                          Icons.add_photo_alternate,
                          size: MediaQuery.of(context).size.width * 0.20,
                          color: Colors.grey,
                        )
                      : null),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.person,
                    controller: nameController,
                    hintText: "Name",
                    isObscure: false,
                  ),
                  CustomTextField(
                    data: Icons.email,
                    controller: emailController,
                    hintText: "Email",
                    isObscure: false,
                  ),
                  CustomTextField(
                    data: Icons.password,
                    controller: passwordController,
                    hintText: "Password",
                    isObscure: true,
                  ),
                  CustomTextField(
                    data: Icons.password,
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    isObscure: true,
                  ),
                  CustomTextField(
                    data: Icons.phone,
                    controller: phoneController,
                    hintText: "Phone",
                    isObscure: false,
                  ),
                  CustomTextField(
                    data: Icons.my_location,
                    controller: locationController,
                    hintText: "Cafe/Restaurant Address",
                    isObscure: false,
                    enabled: false,
                  ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Get Location",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          )),
                      onPressed: () => getCurrentLocation(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10)),
              onPressed: () {
                formValidation();
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
