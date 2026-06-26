import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;
    await user.updateDisplayName(name);
    
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': email,
      'name': name,
      'isAdmin': false,
      'isPremium': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: name,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}