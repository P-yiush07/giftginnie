import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';

class AboutDetailsScreen extends StatelessWidget {
  const AboutDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'About Us',
            style: AppFonts.paragraph.copyWith(
              fontSize: 18,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          surfaceTintColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                "About Us",
                "Welcome to Gift Ginnie, your trusted partner in premium customized corporate gifting, on-demand printing, and high-quality Made-in-India products. With over 15 years of experience, we have established ourselves as a leader in the gifting industry, offering unique, eco-friendly, and personalized gifts for all types of occasions. Whether it's a wedding, birthday, corporate event, conference, or annual day celebration, we are dedicated to making your special moments even more memorable with gifts & our services that truly stand out.",
              ),
              _buildSection(
                "Our Mission",
                "At Gift Ginnie, our mission is to provide you with customized gifting solutions that reflect your values, enhance your brand, and delight the recipient. We specialize in offering a wide variety of products that can be personalized to your needs—whether you are looking for corporate giveaways, wedding favors, or sustainable gifts for any other occasion. We are committed to delivering exceptional products and services with an emphasis on eco-friendliness, customer satisfaction, and lasting impressions.",
              ),
              _buildSection(
                "15+ Years of Expertise",
                "With over 15 years of industry experience, we understand the nuances of custom gifting and the impact a personalized gift can have. Over the years, we've worked with countless businesses, individuals, and organizations across India, gaining in-depth knowledge about their needs, preferences, and expectations. This experience allows us to offer tailored solutions that go beyond just gifting—we help you create connections, enhance your brand image, and make every occasion memorable.",
              ),
              _buildSection(
                "Our Specialization",
                "We take pride in our ability to provide a wide range of products and services to cater to every occasion. Our expertise lies in:",
              ),
              _buildNestedSection([
                {
                  "title": "Customized Corporate Gifting",
                  "content": "Whether you are looking for high-end gifts for clients, personalized merchandise for events, or employee recognition gifts, we offer a range of corporate gifting solutions designed to elevate your brand. From custom-branded stationery and tech gadgets to luxury items, our gifts help you make a lasting impression in the corporate world.",
                },
                {
                  "title": "On-Demand Printing",
                  "content": "Our advanced printing technology allows us to provide on-demand printing for a wide range of products. From t-shirts and bags to notebooks and mugs, we can print logos, designs, and messages with precision and high quality. Whether it's a small batch or a large order, we ensure each print is vibrant, durable, and perfectly aligned with your vision.",
                },
                {
                  "title": "Eco-Friendly Products",
                  "content": "We are committed to sustainability and offer a range of eco-friendly gifting options, including reusable water bottles, biodegradable products, organic cotton bags, bamboo-based items, and more. Our eco-friendly solutions are perfect for businesses and individuals looking to celebrate responsibly while leaving a positive environmental impact.",
                },
                {
                  "title": "Made in India Products",
                  "content": "All our products are proudly made in India, supporting local artisans and manufacturers. By offering high-quality, handcrafted products, we contribute to the growth of India's economy while delivering exceptional gifting solutions for our clients.",
                },
              ]),
              _buildSection(
                "Why Eco-Friendly Matters to Us",
                "Sustainability is at the heart of everything we do. Our eco-friendly products are not just good for the planet—they are also designed to be stylish, functional, and practical for everyday use. Whether it's a bamboo pen, an organic cotton tote, or a recycled material notebook, we offer products that align with today's values of conscious consumption. Our goal is to reduce the environmental impact of gifting while offering innovative products that reflect your commitment to a greener future.",
              ),
              _buildSection(
                "Technology-Driven Excellence",
                "At Gift Ginnie, we believe that innovation is key to delivering the best results. Our state-of-the-art technology and machinery ensure precision, quality, and efficiency in every product we create. From high-definition printing to laser engraving and embroidery, our advanced equipment allows us to produce products that meet the highest standards.\n\nWe offer both small and large-scale production, ensuring fast turnaround times without compromising on quality. Whether you're looking for a few custom gifts or hundreds of personalized items, we are equipped to handle orders of any size with utmost professionalism.",
              ),
              _buildSection(
                'Customer Satisfaction: Our Primary Vision',
                'Customer satisfaction is the core of our business philosophy. We believe in building long-lasting relationships with our clients, and our focus on delivering exceptional products and services ensures that we meet and exceed your expectations. Our goal is not just to provide you with the perfect gift, but to ensure that your experience with us is smooth, enjoyable, and hassle-free.\n\nWe listen to our clients, understand their requirements, and work closely with them throughout the process to deliver personalized solutions that fit their needs. Our team is dedicated to providing excellent customer service, and we strive to ensure that every client is completely satisfied, which is why many of our clients return to us for their future gifting needs.',
              ),
              _buildSection(
                'Join Our Journey',
                'Be part of our growing community of thoughtful gift-givers. Together, let\'s make every celebration more special with perfectly chosen gifts.',
              ),
              _buildSection(
                "Why Choose Us?",
                "We pride ourselves on offering exceptional services and solutions for all your gifting needs:",
              ),
              _buildNestedSection([
                {
                  "title": "Customization Excellence",
                  "content": "We offer an extensive range of products that can be customized to reflect your brand, occasion, or personal style. From custom logos to unique designs, we make sure your gifts are one-of-a-kind.",
                },
                {
                  "title": "Eco-Friendly Commitment",
                  "content": "We offer a wide range of sustainable gifting options made from renewable, recyclable, and biodegradable materials, ensuring your gifts have a minimal environmental footprint.",
                },
                {
                  "title": "Quality & Innovation",
                  "content": "With over 15 years of experience and state-of-the-art technology, we ensure that every product we deliver is crafted with the highest quality standards and the latest trends in mind.",
                },
                {
                  "title": "Diverse Product Range",
                  "content": "From weddings and birthdays to corporate events, conferences, and annual days, we provide personalized gifting solutions for every occasion.",
                },
                {
                  "title": "Timely Delivery & Customer Care",
                  "content": "We understand the importance of timelines, especially for large events or corporate functions. Our reliable delivery system ensures that your gifts arrive on time, and our customer service team is always ready to assist you.",
                },
                {
                  "title": "In House Printing & Branding Services",
                  "content": "We understand that a gift or any event without personalization or branding is incomplete. So we bring you that latest technology of on demand printing & branding services to make difference to your work.",
                },
              ]),
              _buildSection(
                "Our Promise to You",
                "At Gift Ginnie, we are more than just a gifting company—we are your partner in creating meaningful moments. Whether you are celebrating a milestone, promoting your brand, or hosting an event, we are here to help you make a lasting impression with customized gifts that reflect your vision.\n\nCustomer satisfaction is our top priority, and we are committed to providing you with an exceptional experience from start to finish. With a wide range of customizable products, eco-friendly options, and cutting-edge technology, we aim to be your go-to destination for all your gifting needs.\n\nThank you for choosing Gift Ginnie. We look forward to helping you celebrate your special moments with customized, high-quality gifts that are as unique as you are.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.paragraph.copyWith(
              fontSize: 20,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppFonts.paragraph.copyWith(
              fontSize: 15,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNestedSection(List<Map<String, String>> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ${item["title"]!}',
              style: AppFonts.paragraph.copyWith(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                item["content"]!,
                style: AppFonts.paragraph.copyWith(
                  fontSize: 15,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
}