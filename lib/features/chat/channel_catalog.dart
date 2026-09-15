import 'package:autobus/features/chat/models/chatwoot_inbox.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Messaging channel on Manage Channels; matched to Chatwoot inbox `kind`.
class ChannelOption {
  final String label;
  final String apiSlug;
  final FaIconData icon;
  final Color iconColor;
  final Color tileColor;
  final String linkSubtitle;
  final Set<String> chatwootKinds;
  final bool comingSoon;

  const ChannelOption({
    required this.label,
    required this.apiSlug,
    required this.icon,
    required this.iconColor,
    required this.tileColor,
    required this.linkSubtitle,
    required this.chatwootKinds,
    this.comingSoon = false,
  });

  bool matchesInbox(ChatwootInbox inbox) {
    if (!inbox.isActive) return false;
    if (inbox.kind.isEmpty || inbox.kind == 'api') return false;
    return chatwootKinds.contains(inbox.kind);
  }
}

class LinkedChannel {
  final ChannelOption channel;
  final List<ChatwootInbox> inboxes;

  const LinkedChannel({required this.channel, required this.inboxes});

  String get subtitle {
    if (inboxes.length == 1) {
      final name = inboxes.first.name.trim();
      if (name.isNotEmpty) return name;
    }
    return '${inboxes.length} inboxes';
  }
}

class ChannelCatalog {
  ChannelCatalog._();

  static const List<ChannelOption> all = [
    ChannelOption(
      label: 'Instagram',
      apiSlug: 'instagram',
      icon: FontAwesomeIcons.instagram,
      iconColor: Color(0xFFE60B51),
      tileColor: Color(0xFFE60B51),
      linkSubtitle: 'Link instagram',
      chatwootKinds: {'instagram'},
    ),
    ChannelOption(
      label: 'Whatsapp',
      apiSlug: 'whatsapp',
      icon: FontAwesomeIcons.whatsapp,
      iconColor: Color(0xFF3BBF77),
      tileColor: Color(0xFF3BBF77),
      linkSubtitle: 'Link whatsapp',
      chatwootKinds: {'whatsapp'},
    ),
    ChannelOption(
      label: 'SMS',
      apiSlug: 'sms',
      icon: FontAwesomeIcons.commentSms,
      iconColor: Color(0xFF0EA5E9),
      tileColor: Color(0xFF0EA5E9),
      linkSubtitle: 'Link SMS',
      chatwootKinds: {'sms'},
    ),
    ChannelOption(
      label: 'X',
      apiSlug: 'twitter',
      icon: FontAwesomeIcons.xTwitter,
      iconColor: Colors.white,
      tileColor: Color(0xFF111827),
      linkSubtitle: 'Coming soon',
      chatwootKinds: {'twitter'},
      comingSoon: true,
    ),
  ];

  static ({List<LinkedChannel> linked, List<ChannelOption> unlinked}) partition(
    List<ChatwootInbox> inboxes,
  ) {
    final linked = <LinkedChannel>[];
    final unlinked = <ChannelOption>[];

    for (final channel in all) {
      if (channel.comingSoon) {
        unlinked.add(channel);
        continue;
      }
      final matches =
          inboxes.where((i) => channel.matchesInbox(i)).toList();
      if (matches.isNotEmpty) {
        linked.add(LinkedChannel(channel: channel, inboxes: matches));
      } else {
        unlinked.add(channel);
      }
    }

    return (linked: linked, unlinked: unlinked);
  }
}
