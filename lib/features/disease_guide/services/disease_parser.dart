import 'package:flutter/services.dart';

/// Represents a single parsed disease specimen from the markdown database.
class DiseaseSpecimen {
  final String name;
  final String scientificName;
  final String description;
  final List<DiseaseCase> causes;
  final List<ProtocolStep> protocol;
  final int treatmentDurationDays;

  DiseaseSpecimen({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.causes,
    required this.protocol,
    required this.treatmentDurationDays,
  });
}

class DiseaseCase {
  final String title;
  final String description;

  DiseaseCase({required this.title, required this.description});
}

class ProtocolStep {
  final String number;
  final String title;
  final String description;

  ProtocolStep({required this.number, required this.title, required this.description});
}

/// Parses the datecare_disease_database.md file into a list of [DiseaseSpecimen] objects.
/// Adding a new specimen entry to the .md file will automatically generate
/// a new detail page in the app — no code changes needed.
class DiseaseParser {
  static Future<List<DiseaseSpecimen>> loadFromAsset() async {
    final raw = await rootBundle.loadString('assets/datecare_disease_database.md');
    return parse(raw);
  }

  static List<DiseaseSpecimen> parse(String markdown) {
    // CRITICAL: Normalize all line endings to \n (handles Windows \r\n)
    final normalized = markdown.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final specimens = <DiseaseSpecimen>[];

    // Split by --- horizontal rules (with flexible whitespace)
    final blocks = normalized.split(RegExp(r'\n-{3,}\n'));

    for (final block in blocks) {
      // Find the specimen header: ## Specimen XX: NAME
      final nameMatch = RegExp(r'## Specimen \d+:\s*(.+)').firstMatch(block);
      if (nameMatch == null) continue;

      final name = nameMatch.group(1)!.trim();

      // Scientific name: **Scientific Name:** *...*
      final sciMatch = RegExp(r'\*\*Scientific Name:\*\*\s*\*(.+?)\*').firstMatch(block);
      final scientificName = sciMatch?.group(1)?.trim() ?? '';

      // --- Parse "What is it?" section ---
      String description = '';
      final whatIdx = block.indexOf('### 1. What is it?');
      final whyIdx = block.indexOf('### 2. Why did it occur?');
      if (whatIdx != -1 && whyIdx != -1) {
        description = block.substring(whatIdx + '### 1. What is it?'.length, whyIdx).trim();
      }

      // --- Parse "Why did it occur?" section ---
      String causesRaw = '';
      final protoIdx = block.indexOf('### 3. Restoration Protocol');
      if (whyIdx != -1 && protoIdx != -1) {
        causesRaw = block.substring(whyIdx + '### 2. Why did it occur?'.length, protoIdx).trim();
      }
      final causes = _parseCauses(causesRaw);

      // --- Parse "Restoration Protocol" section ---
      String protoRaw = '';
      int treatmentDurationDays = 14; // Default
      
      final durationIdx = block.indexOf('### 4. Treatment Duration');
      
      if (protoIdx != -1) {
        if (durationIdx != -1) {
           protoRaw = block.substring(protoIdx + '### 3. Restoration Protocol'.length, durationIdx).trim();
           
           // Parse duration
           final durationRaw = block.substring(durationIdx + '### 4. Treatment Duration'.length).trim();
           final match = RegExp(r'(\d+)\s*days', caseSensitive: false).firstMatch(durationRaw);
           if (match != null) {
             treatmentDurationDays = int.tryParse(match.group(1)!) ?? 14;
           }
        } else {
           protoRaw = block.substring(protoIdx + '### 3. Restoration Protocol'.length).trim();
        }
      }
      
      final protocol = _parseProtocol(protoRaw);

      specimens.add(DiseaseSpecimen(
        name: name,
        scientificName: scientificName,
        description: description,
        causes: causes,
        protocol: protocol,
        treatmentDurationDays: treatmentDurationDays,
      ));
    }

    return specimens;
  }

  /// Parses bullet points like: * **Title:** Description
  static List<DiseaseCase> _parseCauses(String raw) {
    final results = <DiseaseCase>[];
    final lines = raw.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      final match = RegExp(r'^\*\s+\*\*(.+?):\*\*\s*(.+)$').firstMatch(trimmed);
      if (match != null) {
        results.add(DiseaseCase(
          title: match.group(1)!.trim(),
          description: match.group(2)!.trim(),
        ));
      }
    }
    return results;
  }

  /// Parses numbered steps like: 1. **Title:** Description
  static List<ProtocolStep> _parseProtocol(String raw) {
    final results = <ProtocolStep>[];
    final lines = raw.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      final match = RegExp(r'^(\d+)\.\s+\*\*(.+?):\*\*\s*(.+)$').firstMatch(trimmed);
      if (match != null) {
        results.add(ProtocolStep(
          number: match.group(1)!.trim(),
          title: match.group(2)!.trim(),
          description: match.group(3)!.trim(),
        ));
      }
    }
    return results;
  }
}
