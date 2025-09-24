import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> fetchUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<UserModel> fetchUser(String id) async {
    // TODO: Implement API call with dio
    return UserModel(id: id, name: 'Mock User');
  }
}
