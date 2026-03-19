import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';

/// Persists ITR-1 form drafts to SharedPreferences, keyed by filing job ID.
///
/// Storage key format: `itr1_draft_<jobId>`
class DraftStorageService {
  DraftStorageService._();

  static const _prefix = 'itr1_draft_';

  /// Save the current form data for a filing job.
  static Future<void> saveDraft(String jobId, Itr1FormData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(data.toJson());
    await prefs.setString('$_prefix$jobId', json);
  }

  /// Load a previously saved draft. Returns `null` if none exists.
  static Future<Itr1FormData?> loadDraft(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$jobId');
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Itr1FormData.fromJson(map);
  }

  /// Delete the draft for a filing job (e.g. after successful export/filing).
  static Future<void> deleteDraft(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$jobId');
  }

  /// List all job IDs that have saved drafts.
  static Future<List<String>> listDraftJobIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .where((k) => k.startsWith(_prefix))
        .map((k) => k.substring(_prefix.length))
        .toList();
  }
}
