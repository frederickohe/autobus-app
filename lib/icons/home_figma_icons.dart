import 'package:flutter/widgets.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

/// HOME / Intelligence icons mapped to Apple SF Symbols (SF Pro icon set).
class HomeFigmaIcons {
  HomeFigmaIcons._();

  /// Header sparkle and AI FAB.
  static const ai = SFIcons.sf_sparkles;

  /// Notification bell in the home header.
  static const notificationBing = SFIcons.sf_bell;

  /// Messaging tool card.
  static const wechat = SFIcons.sf_bubble_left_and_bubble_right_fill;

  /// Inbox tool card.
  static const inbox = SFIcons.sf_envelope_fill;

  /// Marketing tool card.
  static const affiliateMarketing =
      SFIcons.sf_point_3_filled_connected_trianglepath_dotted;

  /// Customers tool card.
  static const customers = SFIcons.sf_person_2_fill;

  /// Products tool card.
  static const bag2 = SFIcons.sf_bag_fill;

  /// Orders tool card.
  static const orders = SFIcons.sf_receipt_fill;

  /// Intelligence header — info in speech bubble.
  static const info = SFIcons.sf_info_bubble_fill;

  /// Intelligence Files card.
  static const files = SFIcons.sf_folder_fill;

  /// Intelligence Websites card.
  static const website = SFIcons.sf_globe;

  /// Credits pill token icon.
  static const token = SFIcons.sf_seal_fill;

  /// Analytics header filter.
  static const analyticsFilter = SFIcons.sf_line_3_horizontal_decrease;

  /// Analytics header refresh.
  static const analyticsRefresh = SFIcons.sf_arrow_clockwise;

  /// Analytics revenue hero card.
  static const analyticsRevenue = SFIcons.sf_chart_line_uptrend_xyaxis;

  /// Detailed report cards.
  static const analyticsFinancial = SFIcons.sf_dollarsign_circle_fill;
  static const analyticsOrdersReport = SFIcons.sf_document_fill;
  static const analyticsInvoices = SFIcons.sf_list_bullet_rectangle_fill;
  static const analyticsInventory = SFIcons.sf_shippingbox_fill;
  static const analyticsEngagement = SFIcons.sf_bubble_left_fill;

  // —— Hub sub-screens ——

  static const addCustomer = SFIcons.sf_person_badge_plus;
  static const viewCustomers = SFIcons.sf_text_book_closed_fill;

  static const addProduct = SFIcons.sf_bag_fill_badge_plus;
  static const viewProducts = SFIcons.sf_archivebox_fill;

  static const pendingOrders = SFIcons.sf_clock_fill;
  static const allOrders = SFIcons.sf_receipt_fill;

  static const createCampaign = SFIcons.sf_megaphone_fill;
  static const linkSocial = SFIcons.sf_link;
  static const unlink = SFIcons.sf_xmark_circle_fill;
  static const recentCampaigns = SFIcons.sf_text_document_fill;

  static const linkChannel = SFIcons.sf_link;
  static const liveChats =
      SFIcons.sf_bubble_left_and_exclamationmark_bubble_right_fill;
  static const allChats = SFIcons.sf_bubble_left_and_bubble_right_fill;

  static const startInteraction =
      SFIcons.sf_bubble_left_and_text_bubble_right_fill;
  static const viewInteractions =
      SFIcons.sf_clock_arrow_trianglehead_counterclockwise_rotate_90;

  static const sendMail = SFIcons.sf_paperplane_fill;
  static const sentEmails = SFIcons.sf_envelope_badge_fill;
  static const fromEmail = SFIcons.sf_at;

  static const marketingPictures = SFIcons.sf_photo_fill;
  static const marketingVideos = SFIcons.sf_video_fill;
  static const marketingText = SFIcons.sf_text_document_fill;

  // —— Utility ——

  static const refresh = SFIcons.sf_arrow_clockwise;
  static const warning = SFIcons.sf_exclamationmark_triangle_fill;
  static const cloudOff = SFIcons.sf_icloud_slash_fill;
  static const settings = SFIcons.sf_gearshape_fill;
  static const lock = SFIcons.sf_lock_fill;
  static const add = SFIcons.sf_plus;
  static const microphone = SFIcons.sf_microphone;
  static const close = SFIcons.sf_xmark;
  static const edit = SFIcons.sf_pencil;
  static const delete = SFIcons.sf_trash_fill;
  static const check = SFIcons.sf_checkmark_circle_fill;
  static const checkmark = SFIcons.sf_checkmark;
  static const chevronLeft = SFIcons.sf_chevron_left;
  static const chevronRight = SFIcons.sf_chevron_right;
  static const chevronUp = SFIcons.sf_chevron_up;
  static const chevronDown = SFIcons.sf_chevron_down;
  static const arrowForward = SFIcons.sf_arrow_forward;

  static const camera = SFIcons.sf_camera_fill;
  static const photoLibrary = SFIcons.sf_photo_stack_fill;
  static const photoOnRectangle = SFIcons.sf_photo_on_rectangle;
  static const play = SFIcons.sf_play_circle_fill;
  static const film = SFIcons.sf_film_fill;
  static const download = SFIcons.sf_square_and_arrow_down_fill;
  static const share = SFIcons.sf_square_and_arrow_up;
  static const schedule = SFIcons.sf_calendar;
  static const addCircle = SFIcons.sf_plus_circle;
  static const brokenImage = SFIcons.sf_photo_badge_exclamationmark;

  // —— Hub card gradients (match home dashboard) ——

  static const inboxGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
  );

  static const messagingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF059669)],
  );

  static const marketingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
  );

  static const customersGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
  );

  static const addCustomerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBE24), Color(0xFFD97706)],
  );

  static const viewCustomersGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF969696), Color(0xFF0A0103)],
  );

  static const productsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
  );

  static const addProductGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22D3EE), Color(0xFF0891B2)],
  );

  static const viewProductsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF969696), Color(0xFF0A0103)],
  );

  static const ordersGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22D3EE), Color(0xFF0891B2)],
  );

  static const filesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22D3EE), Color(0xFF0891B2)],
  );

  static const websitesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA3E635), Color(0xFF65A30D)],
  );

  static const sendMailGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
  );

  static const sentEmailsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF985EF), Color(0xFFA20295)],
  );

  static const fromEmailGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2B799), Color(0xFFD64700)],
  );

  /// Inbox — Link Channel (Figma `3399:2129`).
  static const linkChannelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF969696), Color(0xFF0A0103)],
  );

  /// Inbox — Live Chats (Figma `3399:2137`).
  static const liveChatsGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFA6DD57), Color(0xFF4D7C0B)],
  );

  /// Inbox — All Chats (Figma `3399:2146`).
  static const allChatsGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFACDED8), Color(0xFF17897A)],
  );

  static const interactionsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
  );

  static const marketingPicturesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
  );

  static const marketingVideosGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
  );

  static const marketingTextGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
  );
}

/// Renders an SF Symbol with sizing aligned to previous Iconify usage.
class HomeSfIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final FontWeight? fontWeight;

  const HomeSfIcon({
    super.key,
    required this.icon,
    required this.size,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SFIcon(
      icon,
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
