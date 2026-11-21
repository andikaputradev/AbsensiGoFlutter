import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absensigo/controllers/Student/SignupStudentController.dart';
import 'package:absensigo/utils/SearchableDropdown.dart';

class SignupStudent extends StatelessWidget {
  SignupStudent({super.key});
  final SignupStudentController controller = Get.put(SignupStudentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Registrasi Pegawai",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pendaftaran akun dan profil pegawai baru",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Bagian 1: Informasi Kepegawaian
                const Text(
                  "Informasi Kepegawaian",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),

                _sectionCard([
                  // Input 1: Nomor Induk Pegawai (NIP)
                  _inputField(
                    controller.registrationNumber,
                    "Nomor Induk Pegawai (NIP)",
                    Icons.badge_outlined,
                    (v) => (v == null || v.trim().isEmpty) ? 'NIP wajib diisi' : null,
                    context,
                    hintText: "Contoh: DCI-2026-001",
                  ),
                  const SizedBox(height: 16),

                  // Input 2: Divisi / Departemen
                  SearchableDropdown(
                    items: controller.courses,
                    label: "Divisi / Departemen",
                    selected: controller.selectedCourse,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Pilih Divisi / Departemen'
                                : null,
                  ),

                  const SizedBox(height: 16),

                  // Input 3: Jabatan / Posisi
                  _dropdown(
                    controller.years,
                    "Jabatan / Posisi",
                    controller.selectedYear,
                    context,
                  ),
                ], context),

                const SizedBox(height: 24),

                // Bagian 2: Informasi Pribadi & Akun
                const Text(
                  "Informasi Pribadi & Akun",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),

                _sectionCard([
                  // Input 4: Nama Lengkap Pegawai
                  _inputField(
                    controller.name,
                    "Nama Lengkap Pegawai",
                    Icons.person_outline,
                    (v) => (v == null || v.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
                    context,
                    hintText: "Contoh: Andika Putra",
                  ),
                  const SizedBox(height: 16),

                  // Input 5: Email Pegawai
                  _inputField(
                    controller.email,
                    "Email Pegawai",
                    Icons.email_outlined,
                    (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                      return null;
                    },
                    context,
                    hintText: "Contoh: pegawai@diengcyber.com",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Input 6: Kata Sandi
                  Obx(
                    () => _passwordField(
                      controller.password,
                      "Kata Sandi",
                      controller.obscurePassword.value,
                      controller.togglePasswordVisibility,
                      context,
                    ),
                  ),
                ], context),

                const SizedBox(height: 28),

                // Tombol Utama Bawah: Simpan Data Pegawai
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Simpan Data Pegawai",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text.rich(
                      TextSpan(
                        text: "Sudah memiliki akun? ",
                        style: TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: "Masuk di sini",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(List<Widget> children, BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.onSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator,
    BuildContext context, {
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      cursorColor: Colors.blue,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(icon, color: Colors.grey[600]),
        ),
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        labelStyle: const TextStyle(color: Colors.blue),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label,
    bool obscure,
    VoidCallback toggle,
    BuildContext context,
  ) {
    return TextFormField(
      cursorColor: Colors.blue,
      controller: controller,
      obscureText: obscure,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
        if (v.length < 6) return 'Kata sandi minimal 6 karakter';
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(Icons.lock_outline, color: Colors.grey[600]),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[600],
          ),
          onPressed: toggle,
        ),
        labelText: label,
        hintText: "Minimal 6 karakter",
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        labelStyle: const TextStyle(color: Colors.blue),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _dropdown(
    RxList<String> items,
    String label,
    RxString selected,
    BuildContext context,
  ) {
    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue: selected.value.isEmpty ? null : selected.value,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (v) => selected.value = v ?? '',
        validator: (v) => (v == null || v.isEmpty) ? 'Pilih $label' : null,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.work_outline, color: Colors.grey[600]),
          ),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blue),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
