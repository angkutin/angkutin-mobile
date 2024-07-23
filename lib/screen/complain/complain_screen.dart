// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/provider/complain/complain_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:angkutin/data/model/UserModel.dart';
import 'package:angkutin/widget/CustomButton.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../database/storage_service.dart';

class ComplainScreen extends StatefulWidget {
  final User userData;
  static const ROUTE_NAME = '/complain-screen';

  const ComplainScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<ComplainScreen> createState() => _ComplainScreenState();
}

class _ComplainScreenState extends State<ComplainScreen> {
  File? image;
  String? imgUrl;
  final ImageService imageService = ImageService();
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submitComplaint() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Process the complaint
        final title = _titleController.text;
        final content = _contentController.text;
        DateTime now = DateTime.now();

        // Complaint doc/id
        final complaintId =
            FirebaseFirestore.instance.collection('complaints').doc().id;

        // upload image
        if (image != null) {
          try {
            setState(() {
              isLoading = true;
            });
            final storageService = StorageService();
            imgUrl = await storageService.uploadImage(
                "complaints", complaintId, image!);
          } catch (e) {
            print(e);
          }
        }

        // Send the complaint to the server or database

        final provider = Provider.of<ComplainProvider>(context, listen: false);

        await provider.sendComplain(
            widget.userData, complaintId, title, content, now, imgUrl);

        // Show a success message
        if (provider.state == ResultState.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Keluhan berhasil terkirim, Terima Kasih ^^'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (provider.state == ResultState.loading) {
          setState(() {
            isLoading = true;
          });
        }
      } catch (e) {
        print("Error membuat complaint $e");
      } finally {
        setState(() {
          isLoading = false;
          image = null;
        });
      }

      // Reset the form
      _formKey.currentState?.reset();
      _titleController.clear();
      _contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Lapor Keluhan'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Ada masalah apa?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                    ),
                    _formInput(
                        context,
                        "Masukkan judul keluhan",
                        _titleController,
                        50,
                        2,
                        "Harap masukkan judul keluhan"),
                    const SizedBox(height: 16.0),
                    const Text(
                      "Boleh ceritakan lebih detail?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                    ),
                    _formInput(
                        context,
                        "Penjelasan anda membantu proses peninjauan",
                        _contentController,
                        250,
                        5,
                        "Harap masukkan penjelasan\nuntuk memudahkan proses tinjauan\natas keluhan anda"),
                  ],
                ),
              ),
              const Divider(
                color: Colors.transparent,
              ),
              const Text(
                "Tambahkan bukti pendukung (jika ada)",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () async {
                  await imageService.pickImageFromGallery();
                  setState(() {
                    image = imageService.image;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SizedBox(
                    height: 160,
                    child: image != null
                        ? Image.file(
                            image!,
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: dotenv.env['PROOF_COMPLAINT']!,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.transparent,
              ),
              isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      width: 120,
                      child: CustomButton(
                          title: "Kirim Keluhan", onPressed: _submitComplaint))
            ],
          ),
        ),
      ),
    );
  }

  Container _formInput(
      BuildContext context,
      String title,
      TextEditingController controller,
      int maxLength,
      int maxLines,
      String validatorText) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8),
          hintText: title,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText;
          }
          return null;
        },
      ),
    );
  }
}
