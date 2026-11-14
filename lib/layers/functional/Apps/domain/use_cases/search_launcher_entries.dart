import '../entities/label_normalizer.dart';
import '../entities/launcher_entry.dart';

class SearchLauncherEntries {
  const SearchLauncherEntries();

  List<LauncherEntry> call(List<LauncherEntry> entries, String query) {
    final String needle = LabelNormalizer.normalize(query);
    if (needle.isEmpty) {
      return const <LauncherEntry>[];
    }
    final List<LauncherEntry> prefixMatches = <LauncherEntry>[];
    final List<LauncherEntry> wordMatches = <LauncherEntry>[];
    final List<LauncherEntry> containsMatches = <LauncherEntry>[];
    for (final LauncherEntry entry in entries) {
      if (entry.sortKey.startsWith(needle)) {
        prefixMatches.add(entry);
      } else if (entry.sortKey.split(' ').any((String word) => word.startsWith(needle))) {
        wordMatches.add(entry);
      } else if (entry.sortKey.contains(needle)) {
        containsMatches.add(entry);
      }
    }
    return List<LauncherEntry>.unmodifiable(<LauncherEntry>[...prefixMatches, ...wordMatches, ...containsMatches]);
  }
}
