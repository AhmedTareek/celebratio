import 'package:celebratio/Model/event.dart';
import 'package:flutter/material.dart';
import 'package:celebratio/Model/gift.dart';
import 'gift_controller.dart';
import 'edit_gift_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftDetails extends StatefulWidget {
  final String giftId;
  final FbEvent event;
  final GiftController controller;

  const GiftDetails({
    super.key,
    required this.giftId,
    required this.controller,
    required this.event,
  });

  @override
  State<StatefulWidget> createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
  late Gift gift;
  late VoidCallback _listener;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    gift = widget.controller.getGiftById(widget.giftId);
    _listener = () {
      if (mounted) {
        setState(() {
          gift = widget.controller.getGiftById(widget.giftId);
        });
      }
    };
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = widget.controller.currentEvent.createdBy == loggedInUserId;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: isOwner && gift.status == 'Available'
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push<Gift>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGiftPage(
                      controller: widget.controller,
                      gift: gift,
                      onSave: (updatedGift) async {
                        // Update the controller with the updated gift
                        bool result =
                            await widget.controller.editGift(updatedGift);
                        if (result) {
                          // Update the state with the new gift values
                          setState(() {
                            gift.name = updatedGift.name;
                            gift.price = updatedGift.price;
                            gift.description = updatedGift.description;
                            gift.category = updatedGift.category;
                          });
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Error updating gift you may be offline '
                                    'or the gift is already pledged')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
              child: const Icon(Icons.edit),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(theme, gift.imageUrl),
              _buildGiftInfo(theme, gift),
              _buildPriceAndStatus(theme, gift),
              _buildDescription(theme, gift),
              if (!isOwner && gift.status == 'Available')
                _buildPledgeButton(theme, gift),
              if (gift.syncAction == 'draft') _buildPublishButton(theme, gift),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(ThemeData theme, String? url) {
    return Stack(
      children: [
        Image.network(
          url ??
              'https://platform.vox.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/23324816/elden_1.png?quality=90&strip=all&crop=7.8125,0,84.375,100',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Container(
              width: double.infinity,
              height: 250,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off,
                        size: 50, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      'No Internet Connection',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      'Please check your connection to view the image.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            );
          },
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
        Positioned(
          top: 16,
          left: 16,
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGiftInfo(ThemeData theme, Gift gift) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gift.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                gift.category,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndStatus(ThemeData theme, Gift gift) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${gift.price}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          CircleAvatar(
            backgroundColor:
                gift.status == 'Available' ? Colors.green : Colors.red,
            radius: 15,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, Gift gift) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        gift.description,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildPledgeButton(ThemeData theme, Gift gift) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    bool result = await widget.controller.pledgeGift(
                      creatorId: widget.event.createdBy,
                      giftId: gift.id,
                      userId: loggedInUserId,
                    );
                    if (result) {
                      setState(() {
                        gift.status = 'Pledged';
                        gift.pledgedBy = loggedInUserId;
                      });
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('gift already pledged')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Error pledging gift: ${e.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Text(
                  'Pledge This Gift',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPublishButton(ThemeData theme, Gift gift) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await widget.controller.publishGift(gift);
                    if (mounted) {
                      setState(() {
                        widget.controller.fetchGifts();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gift published successfully')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Error publishing gift: ${e.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Text(
                  'Publish This Gift',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
      ),
    );
  }
}
