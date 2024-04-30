  // const Spacer(),
        // signInProvider.isUpdateLoading == true
        //     ? const Center(
        //         child: CircularProgressIndicator(),
        //       )
        //     : SizedBox(
        //         width: mediaQueryWidth(context),
        //         child:
        //         CustomButton(
        //           title: 'Berikutnya',
        //           onPressed: () async {
        //             if (_nomorAktifctrl.text.isNotEmpty &&
        //                 _namaLengkapctrl.text.isNotEmpty) {
        //               await signInProvider.readUserDataLocally();
        //               String emailRef = signInProvider.currentUser!.email;

        //               final Map<String, dynamic> data = {
        //                 'fullName': _namaLengkapctrl.text,
        //                 'role': 'masyarakat',
        //                 'active_phone': _nomorAktifctrl.text,
        //                 'opt_phone': _nomorCadanganctrl.text,
        //               };
        //               await signInProvider.updateUserDataProv(emailRef, data);

        //               final state = signInProvider.updateState;
        //               if (state == ResultState.success) {
        //                 showInfoSnackbar(context, "berhasil");
        //               } else {
        //                 showInfoSnackbar(context, "gagal");
        //               }
        //             } else {
        //               showInfoSnackbar(
        //                   context, "Periksa kembali kolom pengisian");
        //             }
        //           },
        //         ),

        //       ),