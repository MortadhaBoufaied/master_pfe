class FileData {
  final String id;
  final String filename;
  final String filepath;
  final String? fileUrl;
  final String? uploadedBy;
  final String? uploadedAt;

  FileData({
    required this.id,
    required this.filename,
    required this.filepath,
    this.fileUrl,
    this.uploadedBy,
    this.uploadedAt,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['filePath'] ?? json['filepath'] ?? json['filename'] ?? json['originalName'];
    final filenameRaw = json['filename'] ?? json['originalName'] ?? idRaw;
    final filepathRaw = json['filepath'] ?? json['filePath'] ?? json['path'] ?? filenameRaw;
    return FileData(
      id: (idRaw ?? '').toString(),
      filename: (filenameRaw ?? '').toString(),
      filepath: (filepathRaw ?? '').toString(),
      fileUrl: json['fileUrl']?.toString() ?? json['url']?.toString(),
      uploadedBy: json['uploadedBy'],
      uploadedAt: json['uploadedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'filepath': filepath,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
    };
  }
}


