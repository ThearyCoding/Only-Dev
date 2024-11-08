import 'package:e_leaningapp/screens/user-screens/user_information_screen.dart';

class TabItem extends StatelessWidget {
  final String title;
  final int count;
  const TabItem({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
          ),
          count > 0
              ? Container(
                  margin: const EdgeInsetsDirectional.only(start: 5),
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      count > 9 ? "9+" : count.toString(),
                      style: TextStyle(
                          color: Colors.white.withOpacity(.7), fontSize: 10),
                    ),
                  ),
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                )
        ],
      ),
    );
  }
}
