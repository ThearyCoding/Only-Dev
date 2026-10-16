import '../../core/constants.dart';

class ApiService {
  static final List<String> _videos = [
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/compressed_videos%2F1000000034_compress.mp4?alt=media&token=a4de676a-b4ef-4aca-aa63-ade365c463e5",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2FSnaptik.app_7417369066639215889_compress.mp4?alt=media&token=d2c7b919-6d05-40d8-af57-a45704b94aaf",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2FSnaptik.app_7423325890014154002_compress.mp4?alt=media&token=99601089-791e-4c14-93cd-2f8344269291",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2FSnaptik.app_7431056964236463368_compress.mp4?alt=media&token=8772c5ad-8fbb-4538-bd6d-c145464e53c3",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2FSnaptik.app_7424831462232558894_compress.mp4?alt=media&token=4e30a496-9c83-437b-ad08-b836670ef7f6",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2FSnaptik.app_7430838542462455048_compress.mp4?alt=media&token=e1db6520-c3af-4b8c-b77b-071f977f1e62",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2FSnaptik.app_7430647616460868910_compress.mp4?alt=media&token=df26f023-a920-4408-a86a-f3cd6c9e71df",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2Fb39632e5427fd47bbab8161fcd29f770_compress.mp4?alt=media&token=bc8179dd-bd1d-4edf-9e7d-b9a7578fc2d1",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F10faf23e25e30202934f01c8988dba66_compress.mp4?alt=media&token=b8e66d2f-af49-4903-b5d9-bb9fad810f3f",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F2b857a49f3ec74650ff545e04b2ca9c6_compress.mp4?alt=media&token=cb951b9d-1093-4339-a0e4-0abe57271a62",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2Fb05a20111c0cbd98e467fa38957bd991_compress.mp4?alt=media&token=02c92804-87e1-4177-8360-94ca836f3416",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2FSnaptik.app_7431581594491669768_compress.mp4?alt=media&token=d5fb8b7a-e712-4d23-9a05-94be4eac4222",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F5cee81879d339b35c2baef447234d2c2_compress.mp4?alt=media&token=5517b49a-7a4f-44a6-99f9-62e643ac421b",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2Fbd28dae6c72a728b1f6d6b344dea8765_compress.mp4?alt=media&token=2d8ed230-f1b2-46fe-b709-f33861e7541a",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F28caf5db829da55fa88485f062f7c55d_compress.mp4?alt=media&token=9d1671ea-bbf7-4014-80d0-85cd80c3439e",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F3ffca492295ee5f0f62ac654ca00388c_compress.mp4?alt=media&token=ab6f8c43-1577-4f60-929f-7a0382392ec1",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F8430f1aaea4ae4e2afe9410e6ab79b62_compress.mp4?alt=media&token=36f27bed-8b26-45bf-8043-8db7e19a0715",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2Fbbb58ed5d4b11f0be43a49427cc97f4d_compress.mp4?alt=media&token=33aa4d22-bba8-44c8-a372-2658b6df1c7c",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F7365ce022dc560944373874a000a942a_compress.mp4?alt=media&token=37e74720-0e66-4785-b5ed-26b34a1f94ca",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2Fe8fa402d75e27ecefa8428aee3615f2f_compress.mp4?alt=media&token=3cd1bf29-db76-495e-8824-288a6dc1725a",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F81890d7563c53b659b8210a3543cbf77_compress.mp4?alt=media&token=db5231da-efb7-4e0f-93f8-45296ce1243c",
    "https://firebasestorage.googleapis.com/v0/b/elearning-app-a6e15.appspot.com/o/uploads%2F21a9df6996e36900ed8702d6640f787c_compress.mp4?alt=media&token=8becef78-7fe9-44c6-9ab1-e8fdbbc91bb5"
  ];

  /// Simulate api call
  static Future<List<String>> getVideos({int id = 0}) async {
    // No more videos
    if ((id >= _videos.length)) {
      return [];
    }

    await Future.delayed(const Duration(seconds: kLatency));

    if ((id + kNextLimit >= _videos.length)) {
      return _videos.sublist(id, _videos.length);
    }

    return _videos.sublist(id, id + kNextLimit);
  }
}
