/// Model untuk data BotcahX API
/// Author: Tamas dari TamsHub
///
/// Model ini merepresentasikan data dari API BotcahX seperti
/// chat response, image generation, download, dan tools lainnya.

/// Model untuk informasi API
class BotcahXApiInfo {
  final String name;
  final String version;
  final String description;
  final String author;
  final List<String> endpoints;

  BotcahXApiInfo({
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.endpoints,
  });

  factory BotcahXApiInfo.fromJson(Map<String, dynamic> json) {
    return BotcahXApiInfo(
      name: json['name']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      endpoints: json['endpoints'] != null
          ? List<String>.from(json['endpoints'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'author': author,
      'endpoints': endpoints,
    };
  }
}

/// Model untuk response chat GPT
class BotcahXChatResponse {
  final bool success;
  final String message;
  final String? response;
  final String? model;
  final int? tokens;

  BotcahXChatResponse({
    required this.success,
    required this.message,
    this.response,
    this.model,
    this.tokens,
  });

  factory BotcahXChatResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXChatResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      response: json['response']?.toString(),
      model: json['model']?.toString(),
      tokens: json['tokens'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'response': response,
      'model': model,
      'tokens': tokens,
    };
  }
}

/// Model untuk response generate image
class BotcahXImageResponse {
  final bool success;
  final String message;
  final String? imageUrl;
  final String? prompt;
  final String? model;
  final String? size;

  BotcahXImageResponse({
    required this.success,
    required this.message,
    this.imageUrl,
    this.prompt,
    this.model,
    this.size,
  });

  factory BotcahXImageResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXImageResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['url']?.toString(),
      prompt: json['prompt']?.toString(),
      model: json['model']?.toString(),
      size: json['size']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'image_url': imageUrl,
      'prompt': prompt,
      'model': model,
      'size': size,
    };
  }
}

/// Model untuk response download
class BotcahXDownloadResponse {
  final bool success;
  final String message;
  final String? title;
  final String? downloadUrl;
  final String? thumbnailUrl;
  final String? duration;
  final String? quality;
  final String? fileSize;

  BotcahXDownloadResponse({
    required this.success,
    required this.message,
    this.title,
    this.downloadUrl,
    this.thumbnailUrl,
    this.duration,
    this.quality,
    this.fileSize,
  });

  factory BotcahXDownloadResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXDownloadResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      title: json['title']?.toString(),
      downloadUrl: json['download_url']?.toString() ?? json['url']?.toString(),
      thumbnailUrl: json['thumbnail']?.toString(),
      duration: json['duration']?.toString(),
      quality: json['quality']?.toString(),
      fileSize: json['file_size']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'title': title,
      'download_url': downloadUrl,
      'thumbnail': thumbnailUrl,
      'duration': duration,
      'quality': quality,
      'file_size': fileSize,
    };
  }
}

/// Model untuk response Instagram stalk
class BotcahXInstagramResponse {
  final bool success;
  final String message;
  final String? username;
  final String? fullName;
  final String? bio;
  final String? profilePicUrl;
  final int? followers;
  final int? following;
  final int? posts;
  final bool? isPrivate;
  final bool? isVerified;

  BotcahXInstagramResponse({
    required this.success,
    required this.message,
    this.username,
    this.fullName,
    this.bio,
    this.profilePicUrl,
    this.followers,
    this.following,
    this.posts,
    this.isPrivate,
    this.isVerified,
  });

  factory BotcahXInstagramResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXInstagramResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      username: json['username']?.toString(),
      fullName: json['full_name']?.toString(),
      bio: json['bio']?.toString(),
      profilePicUrl: json['profile_pic_url']?.toString(),
      followers: json['followers'] as int?,
      following: json['following'] as int?,
      posts: json['posts'] as int?,
      isPrivate: json['is_private'] as bool?,
      isVerified: json['is_verified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'profile_pic_url': profilePicUrl,
      'followers': followers,
      'following': following,
      'posts': posts,
      'is_private': isPrivate,
      'is_verified': isVerified,
    };
  }
}

/// Model untuk response info gempa
class BotcahXGempaResponse {
  final bool success;
  final String message;
  final String? tanggal;
  final String? jam;
  final String? magnitude;
  final String? kedalaman;
  final String? wilayah;
  final String? potensi;
  final String? mapUrl;

  BotcahXGempaResponse({
    required this.success,
    required this.message,
    this.tanggal,
    this.jam,
    this.magnitude,
    this.kedalaman,
    this.wilayah,
    this.potensi,
    this.mapUrl,
  });

  factory BotcahXGempaResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXGempaResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      tanggal: json['tanggal']?.toString(),
      jam: json['jam']?.toString(),
      magnitude: json['magnitude']?.toString(),
      kedalaman: json['kedalaman']?.toString(),
      wilayah: json['wilayah']?.toString(),
      potensi: json['potensi']?.toString(),
      mapUrl: json['map']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'tanggal': tanggal,
      'jam': jam,
      'magnitude': magnitude,
      'kedalaman': kedalaman,
      'wilayah': wilayah,
      'potensi': potensi,
      'map': mapUrl,
    };
  }
}

/// Model untuk response cuaca
class BotcahXCuacaResponse {
  final bool success;
  final String message;
  final String? kota;
  final String? cuaca;
  final String? suhu;
  final String? kelembaban;
  final String? tekananUdara;
  final String? kecepatanAngin;

  BotcahXCuacaResponse({
    required this.success,
    required this.message,
    this.kota,
    this.cuaca,
    this.suhu,
    this.kelembaban,
    this.tekananUdara,
    this.kecepatanAngin,
  });

  factory BotcahXCuacaResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXCuacaResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      kota: json['kota']?.toString(),
      cuaca: json['cuaca']?.toString(),
      suhu: json['suhu']?.toString(),
      kelembaban: json['kelembaban']?.toString(),
      tekananUdara: json['tekanan_udara']?.toString(),
      kecepatanAngin: json['kecepatan_angin']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'kota': kota,
      'cuaca': cuaca,
      'suhu': suhu,
      'kelembaban': kelembaban,
      'tekanan_udara': tekananUdara,
      'kecepatan_angin': kecepatanAngin,
    };
  }
}

/// Model untuk response QR code
class BotcahXQRResponse {
  final bool success;
  final String message;
  final String? qrUrl;
  final String? text;
  final int? size;

  BotcahXQRResponse({
    required this.success,
    required this.message,
    this.qrUrl,
    this.text,
    this.size,
  });

  factory BotcahXQRResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXQRResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      qrUrl: json['qr_url']?.toString() ?? json['url']?.toString(),
      text: json['text']?.toString(),
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'qr_url': qrUrl,
      'text': text,
      'size': size,
    };
  }
}

/// Model untuk response shortlink
class BotcahXShortlinkResponse {
  final bool success;
  final String message;
  final String? originalUrl;
  final String? shortUrl;
  final String? shortCode;

  BotcahXShortlinkResponse({
    required this.success,
    required this.message,
    this.originalUrl,
    this.shortUrl,
    this.shortCode,
  });

  factory BotcahXShortlinkResponse.fromJson(Map<String, dynamic> json) {
    return BotcahXShortlinkResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      originalUrl: json['original_url']?.toString(),
      shortUrl: json['short_url']?.toString(),
      shortCode: json['short_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'original_url': originalUrl,
      'short_url': shortUrl,
      'short_code': shortCode,
    };
  }
}
