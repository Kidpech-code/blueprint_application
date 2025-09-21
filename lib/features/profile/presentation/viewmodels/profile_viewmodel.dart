import 'package:flutter/foundation.dart';
import '../../application/usecases/get_profile_usecase.dart';
import '../../domain/entities/profile_entities.dart';
import '../../../../core/error_handling.dart';

enum ProfileState { initial, loading, loaded, error }

class ProfileViewModel extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;

  ProfileViewModel(this.getProfileUseCase);

  ProfileState _state = ProfileState.initial;
  Profile? _profile;
  ProfileStats? _stats;
  AppError? _error;
  String? _selectedTab;

  // Getters
  ProfileState get state => _state;
  Profile? get profile => _profile;
  ProfileStats? get stats => _stats;
  AppError? get error => _error;
  String? get selectedTab => _selectedTab;
  bool get isLoading => _state == ProfileState.loading;
  bool get hasData => _profile != null;

  // Load Profile
  Future<void> loadProfile(String userId, {String? tab}) async {
    _setState(ProfileState.loading);
    _selectedTab = tab;

    final result = await getProfileUseCase.call(userId);

    result.fold(
      (profile) {
        _profile = profile;
        _setState(ProfileState.loaded);
      },
      (error) {
        _error = error;
        _setState(ProfileState.error);
      },
    );
  }

  // Set Selected Tab
  void setSelectedTab(String? tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // Clear Error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }
}
