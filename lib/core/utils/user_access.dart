import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AppUserRole { psychologist, teacher, other }

class AppUserProfile {
  final String displayName;
  final String email;
  final AppUserRole role;

  const AppUserProfile({
    required this.displayName,
    required this.email,
    required this.role,
  });

  const AppUserProfile.anonymous()
      : displayName = 'Usuario',
        email = '',
        role = AppUserRole.other;

  bool get isPsychologist => role == AppUserRole.psychologist;
}

Future<AppUserProfile> loadCurrentUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const AppUserProfile.anonymous();

  final userData = await _loadUserDoc(user);
  final roleValue = _readString(userData, const ['rol', 'Rol', 'role', 'Role']);
  final firestoreName = _readString(userData, const ['nombre', 'Nombre', 'name', 'Name']);
  final firestoreEmail = _readString(userData, const ['email', 'Email']);

  return AppUserProfile(
    displayName: _resolveDisplayName(user, firestoreName),
    email: (firestoreEmail ?? user.email ?? '').trim(),
    role: _resolveRole(roleValue),
  );
}

Future<Map<String, dynamic>?> _loadUserDoc(User user) async {
  final usuarios = FirebaseFirestore.instance.collection('usuarios');

  final byUid = await usuarios.doc(user.uid).get();
  if (byUid.exists) {
    return byUid.data();
  }

  final email = user.email?.trim();
  if (email == null || email.isEmpty) return null;

  final byEmail = await usuarios.where('email', isEqualTo: email).limit(1).get();
  if (byEmail.docs.isNotEmpty) {
    return byEmail.docs.first.data();
  }

  final lowered = email.toLowerCase();
  if (lowered == email) return null;

  final byLoweredEmail = await usuarios.where('email', isEqualTo: lowered).limit(1).get();
  if (byLoweredEmail.docs.isNotEmpty) {
    return byLoweredEmail.docs.first.data();
  }

  return null;
}

String _resolveDisplayName(User user, String? firestoreName) {
  final fromFirestore = firestoreName?.trim();
  if (fromFirestore != null && fromFirestore.isNotEmpty) return fromFirestore;

  final displayName = user.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) return displayName;

  final email = user.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email.split('@').first;
  }

  return 'Usuario';
}

AppUserRole _resolveRole(String? rawRole) {
  final role = _normalize(rawRole);
  if (role.contains('psicolog')) return AppUserRole.psychologist;
  if (role.contains('maestro') || role.contains('docente') || role.contains('profesor')) {
    return AppUserRole.teacher;
  }
  return AppUserRole.other;
}

String? _readString(Map<String, dynamic>? data, List<String> keys) {
  if (data == null) return null;
  for (final key in keys) {
    final value = data[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String _normalize(String? value) {
  var text = (value ?? '').toLowerCase().trim();
  const from = 'áàäâãåéèëêíìïîóòöôõúùüûñ';
  const to = 'aaaaaaeeeeiiiiooooouuuun';
  for (var i = 0; i < from.length; i++) {
    text = text.replaceAll(from[i], to[i]);
  }
  return text;
}
