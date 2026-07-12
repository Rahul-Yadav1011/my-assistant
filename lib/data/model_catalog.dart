/// Catalog of on-device models the user can download and run offline.
///
/// Every entry here is a real, phone-compatible model in a format the
/// on-device engine can load. This is the "curated shortlist" — reliable,
/// no surprises. A power-user custom URL option lives in the model screen.
class OnDeviceModel {
  final String id;
  final String name;
  final String publisher;
  final String description;
  final double sizeGb; // download size, approx
  final double minRamGb; // recommended free RAM
  final String speedLabel; // "Fast", "Balanced", "Smartest"
  final String downloadUrl; // GGUF / .task URL (used next turn)
  final bool recommended;

  const OnDeviceModel({
    required this.id,
    required this.name,
    required this.publisher,
    required this.description,
    required this.sizeGb,
    required this.minRamGb,
    required this.speedLabel,
    required this.downloadUrl,
    this.recommended = false,
  });

  String get sizeLabel =>
      sizeGb < 1 ? '${(sizeGb * 1000).round()} MB' : '${sizeGb.toStringAsFixed(1)} GB';
  String get ramLabel => '${minRamGb.toStringAsFixed(0)} GB RAM';
}

class ModelCatalog {
  static const List<OnDeviceModel> models = [
    OnDeviceModel(
      id: 'gemma3-1b-it',
      name: 'Gemma 3 1B',
      publisher: 'Google',
      description:
          'Small and quick. Great for phones with limited RAM. Handles general chat, summaries, and simple questions well.',
      sizeGb: 0.55,
      minRamGb: 3,
      speedLabel: 'Fast',
      downloadUrl:
          'https://huggingface.co/google/gemma-3-1b-it-qat-q4_0-gguf/resolve/main/gemma-3-1b-it-q4_0.gguf',
      recommended: true,
    ),
    OnDeviceModel(
      id: 'qwen2.5-1.5b-it',
      name: 'Qwen 2.5 1.5B',
      publisher: 'Alibaba',
      description:
          'Good balance of speed and quality. Strong at reasoning and multilingual chat for its size.',
      sizeGb: 1.0,
      minRamGb: 4,
      speedLabel: 'Balanced',
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
    ),
    OnDeviceModel(
      id: 'gemma3-4b-it',
      name: 'Gemma 3 4B',
      publisher: 'Google',
      description:
          'The smartest option that still fits on a phone. Noticeably better answers, but needs a newer phone with more RAM and downloads more data.',
      sizeGb: 2.5,
      minRamGb: 6,
      speedLabel: 'Smartest',
      downloadUrl:
          'https://huggingface.co/google/gemma-3-4b-it-qat-q4_0-gguf/resolve/main/gemma-3-4b-it-q4_0.gguf',
    ),
  ];

  static OnDeviceModel? byId(String? id) {
    if (id == null) return null;
    for (final m in models) {
      if (m.id == id) return m;
    }
    return null;
  }
}
