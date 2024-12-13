import 'package:flutter/material.dart';
import 'package:celebratio/Model/fb_gift.dart';
import 'gift_controller.dart';
import 'edit_gift_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftDetails extends StatefulWidget {
  final FbGift gift;
  final GiftController controller;

  const GiftDetails({
    super.key,
    required this.gift,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gift = widget.gift;
    final isOwner = widget.controller.currentEvent.createdBy == loggedInUserId;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: isOwner && gift.status == 'Available'
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push<FbGift>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGiftPage(
                      controller: widget.controller,
                      gift: gift,
                      onSave: (updatedGift) async {
                        // Update the controller with the updated gift
                        bool result = await widget.controller.editGift(
                          giftId: updatedGift.id,
                          name: updatedGift.name,
                          price: updatedGift.price,
                          description: updatedGift.description,
                          category: updatedGift.category,
                        );
                        if (result) {
                          // Update the state with the new gift values
                          setState(() {
                            widget.gift.name = updatedGift.name;
                            widget.gift.price = updatedGift.price;
                            widget.gift.description = updatedGift.description;
                            widget.gift.category = updatedGift.category;
                          });
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error updating gift')),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(ThemeData theme,String? url) {
    return Stack(
      children: [
        Image.network(
          url ??'https://platform.vox.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/23324816/elden_1.png?quality=90&strip=all&crop=7.8125,0,84.375,100',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
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

  Widget _buildGiftInfo(ThemeData theme, FbGift gift) {
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

  Widget _buildPriceAndStatus(ThemeData theme, FbGift gift) {
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

  Widget _buildDescription(ThemeData theme, FbGift gift) {
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

  Widget _buildPledgeButton(ThemeData theme, FbGift gift) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            try {
              bool result = await widget.controller.pledgeGift(
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error pledging gift: ${e.toString()}')),
              );
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
}
