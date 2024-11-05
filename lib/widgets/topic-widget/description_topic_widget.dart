import 'package:flutter/material.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:url_launcher/url_launcher.dart';

class DescriptionWidget extends StatefulWidget {
  final String videoDescription;

  const DescriptionWidget({Key? key, required this.videoDescription})
      : super(key: key);

  @override
  DescriptionWidgetState createState() => DescriptionWidgetState();
}

class DescriptionWidgetState extends State<DescriptionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: LinkifyText(
          widget.videoDescription,
          linkTypes: const [
            LinkType.url,
          ],
          linkStyle: const TextStyle(color: Colors.blue),
          onTap: (link) async {
            final url = Uri.parse(link.value!);
      
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
      ),
    );
  }
}
