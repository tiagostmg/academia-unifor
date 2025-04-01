import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academia_unifor/models/users.dart';

// Provider para armazenar o usuário logado
final userProvider = StateProvider<Users?>((ref) => null);
