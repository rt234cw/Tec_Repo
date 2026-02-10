import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tec/core/extensions/localization_extension.dart';
import 'package:tec/core/theme/app_colors.dart';
import '../../domain/entities/meeting_room_ui_model.dart';

class MeetingRoomItem extends StatelessWidget {
  final MeetingRoomUiModel room;

  const MeetingRoomItem({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // 定義灰階濾鏡 (標準黑白濾鏡)
    const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);

    return Card(
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // 底層內容：加上「灰階濾鏡」
          ColorFiltered(
            colorFilter: room.isBookable ? const ColorFilter.mode(Colors.transparent, BlendMode.dst) : greyscaleFilter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 圖片區域
                meetingRoomPicture(),

                // 文字資訊區域
                meetingRoomDescription(textTheme, context)
              ],
            ),
          ),

          // 當會議室是不可用狀態時，要加上遮罩
          if (!room.isBookable) ...[
            // 淡白色遮罩，讓變黑白的內容再變淡一點，看起來更像Disabled
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),

            // Unavailable 標籤
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.block, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Padding meetingRoomDescription(TextTheme textTheme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 會議室名稱
          Text(
            room.info.roomName,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
          // 會議中心名稱
          Text(
            room.centre?.name ?? room.info.centreCode,
            style: textTheme.bodySmall?.copyWith(color: AppColors.gray),
            maxLines: 1,
          ),
          // 座位數與價格
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 16, color: AppColors.gray),
                  const SizedBox(width: 4),
                  Text(
                    // 座位看起來不會有單數的問題，但反正都做了單複數的設計，就直接用單複數參數
                    context.loc.capacitySeats(room.info.capacity),
                    style: textTheme.bodySmall?.copyWith(color: AppColors.gray),
                  ),
                ],
              ),
              Text('${room.price?.currencyCode} ${room.price?.finalPrice.toStringAsFixed(0)}',
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Container meetingRoomPicture() {
    return Container(
        height: 200,
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: room.info.firstImage,
          fit: BoxFit.cover,
          placeholder: (context, url) => Image.asset(
            "assets/images/tec_logo.png",
            fit: BoxFit.contain,
          ),
          errorWidget: (context, url, error) => Center(
              child: Image.asset(
            "assets/images/tec_logo.png",
            fit: BoxFit.cover,
          )),
        ));
  }
}
