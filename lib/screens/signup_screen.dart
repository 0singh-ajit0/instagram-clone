import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';
import 'package:instagram_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _bioController;
  late final TextEditingController _usernameController;
  Uint8List? _image;
  bool _isLoading = false;

  Future<void> initializeDefaultProfilePic() async {
    if (_image != null) return;
    final file = await getImageFromAssets("defaultProfilePic.png");
    _image = await file.readAsBytes();
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _bioController = TextEditingController();
    _usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> selectImage() async {
    Uint8List? image = await pickImage(ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void signUpUser() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods.signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image!,
    );

    setState(() {
      _isLoading = false;
    });

    // if string returned is sucess, user has been created
    if (res == "success") {
      // navigate to the home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      // show the error
      if (context.mounted) {
        showSnackBar(context, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeDefaultProfilePic(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(
              body: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Svg logo
                      Flexible(
                        flex: 2,
                        child: Container(),
                      ),
                      SvgPicture.asset(
                        "assets/ic_instagram.svg",
                        colorFilter: const ColorFilter.mode(
                          primaryColor,
                          BlendMode.srcIn,
                        ),
                        height: 64,
                      ),
                      const SizedBox(height: 64),
                      // Circular Widget to accept and show our selected file
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 64.0,
                            backgroundImage: MemoryImage(_image!),
                            backgroundColor: Colors.transparent,
                          ),
                          Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                              onPressed: () async {
                                await selectImage();
                              },
                              icon: const Icon(Icons.add_a_photo),
                              color: Colors.grey,
                              style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(1),
                                  shadowColor:
                                      MaterialStatePropertyAll(Colors.white38)),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Text field for username
                      TextFieldInput(
                        textEditingController: _usernameController,
                        hintText: "Enter your username",
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),
                      // Text field input for email
                      TextFieldInput(
                        textEditingController: _emailController,
                        hintText: "Enter your email",
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      // Text field input for password
                      TextFieldInput(
                        textEditingController: _passwordController,
                        hintText: "Enter your password",
                        isSecret: true,
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),
                      // Text field for bio
                      TextFieldInput(
                        textEditingController: _bioController,
                        hintText: "Enter your bio",
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),
                      // Signup button
                      InkWell(
                        onTap: signUpUser,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              color: blueColor),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                )
                              : const Text("Sign up"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        flex: 2,
                        child: Container(),
                      ),
                      // Move to sign up / Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: const Text("Already have an account?"),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: const Text(
                                " Login.",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              resizeToAvoidBottomInset: false,
            );
          default:
            return const Scaffold(
              body: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}
