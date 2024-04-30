import 'package:angkutin/common/state_enum.dart';
import 'package:angkutin/common/utils.dart';
import 'package:angkutin/widget/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth/auth_provider.dart';
import '../../widget/CustomButton.dart';
import '../../widget/TitleSectionBlue.dart';

class FillUserDataScreen extends StatefulWidget {
  const FillUserDataScreen({super.key});

  @override
  State<FillUserDataScreen> createState() => _FillDataScreenState();
}

class _FillDataScreenState extends State<FillUserDataScreen> {
  final TextEditingController _namaLengkapctrl = TextEditingController();
  final TextEditingController _nomorAktifctrl = TextEditingController();
  final TextEditingController _nomorCadanganctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize
                .min, // Tambahkan mainAxisSize: MainAxisSize.min di sini

            children: [
              const SizedBox(
                height: 36,
              ),
              const TitleSectionBlue(
                title: 'Data 1/3 ',
              ),
              const Text(
                "Sepertinya anda baru disini! Isi data diri anda",
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 54,
              ),
              CustomTextField(
                text: "Nama Lengkap",
                controller: _namaLengkapctrl,
                hintText: "Udin Samudin",
                width: mediaQueryWidth(context) / 1.2,
                // height: 40,
              ),
              CustomTextField(
                text: "Nomor Aktif",
                controller: _nomorAktifctrl,
                keyboardType: TextInputType.phone,
                hintText: "081234567890",
                width: mediaQueryWidth(context) / 1.2,
              ),
              CustomTextField(
                text: "Nomor Cadangan (opsional)",
                controller: _nomorCadanganctrl,
                keyboardType: TextInputType.phone,
                hintText: "081234567890",
                width: mediaQueryWidth(context) / 1.2,
              ),
              const Spacer(),
              signInProvider.isUpdateLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      width: mediaQueryWidth(context),
                      child: CustomButton(
                        title: 'Berikutnya',
                        onPressed: () async {
                          if (_nomorAktifctrl.text.isNotEmpty &&
                              _namaLengkapctrl.text.isNotEmpty) {
                            await signInProvider.readUserDataLocally();
                            String emailRef = signInProvider.currentUser!.email;

                            final Map<String, dynamic> data = {
                              'fullName': _namaLengkapctrl.text,
                              'role': 'masyarakat',
                              'active_phone': _nomorAktifctrl.text,
                              'opt_phone': _nomorCadanganctrl.text,
                            };
                            await signInProvider.updateUserDataProv(
                                emailRef, data);

                            final state = signInProvider.updateState;
                            if (state == ResultState.success) {
                              showInfoSnackbar(context, "berhasil");
                            } else {
                              showInfoSnackbar(context, "gagal");
                            }
                          } else {
                            showInfoSnackbar(
                                context, "Periksa kembali kolom pengisian");
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
