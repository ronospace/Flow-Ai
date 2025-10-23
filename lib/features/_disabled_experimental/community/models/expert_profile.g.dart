// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expert_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpertProfile _$ExpertProfileFromJson(Map<String, dynamic> json) =>
    ExpertProfile(
      expertId: json['expertId'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      title: json['title'] as String,
      specialties: (json['specialties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      institution: json['institution'] as String,
      licenseNumber: json['licenseNumber'] as String,
      bio: json['bio'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      totalAnswers: (json['totalAnswers'] as num).toInt(),
      acceptedAnswers: (json['acceptedAnswers'] as num).toInt(),
      responseRate: (json['responseRate'] as num).toDouble(),
      averageResponseTime: Duration(
        microseconds: (json['averageResponseTime'] as num).toInt(),
      ),
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      isAvailable: json['isAvailable'] as bool,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      badges: json['badges'] == null
          ? null
          : ExpertBadges.fromJson(json['badges'] as Map<String, dynamic>),
      websiteUrl: json['websiteUrl'] as String?,
      linkedInProfile: json['linkedInProfile'] as String?,
    );

Map<String, dynamic> _$ExpertProfileToJson(ExpertProfile instance) =>
    <String, dynamic>{
      'expertId': instance.expertId,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'title': instance.title,
      'specialties': instance.specialties,
      'credentials': instance.credentials,
      'institution': instance.institution,
      'licenseNumber': instance.licenseNumber,
      'bio': instance.bio,
      'profileImageUrl': instance.profileImageUrl,
      'rating': instance.rating,
      'totalAnswers': instance.totalAnswers,
      'acceptedAnswers': instance.acceptedAnswers,
      'responseRate': instance.responseRate,
      'averageResponseTime': instance.averageResponseTime.inMicroseconds,
      'joinedDate': instance.joinedDate.toIso8601String(),
      'isAvailable': instance.isAvailable,
      'languages': instance.languages,
      'badges': instance.badges,
      'websiteUrl': instance.websiteUrl,
      'linkedInProfile': instance.linkedInProfile,
    };

ExpertBadges _$ExpertBadgesFromJson(Map<String, dynamic> json) => ExpertBadges(
  topContributor: json['topContributor'] as bool? ?? false,
  featured: json['featured'] as bool? ?? false,
  verified: json['verified'] as bool? ?? true,
  quickResponder: json['quickResponder'] as bool? ?? false,
  knowledgeBaseContributor: json['knowledgeBaseContributor'] as bool? ?? false,
  communityModerator: json['communityModerator'] as bool? ?? false,
  specialtyBadges:
      (json['specialtyBadges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  lastBadgeEarned: json['lastBadgeEarned'] == null
      ? null
      : DateTime.parse(json['lastBadgeEarned'] as String),
);

Map<String, dynamic> _$ExpertBadgesToJson(ExpertBadges instance) =>
    <String, dynamic>{
      'topContributor': instance.topContributor,
      'featured': instance.featured,
      'verified': instance.verified,
      'quickResponder': instance.quickResponder,
      'knowledgeBaseContributor': instance.knowledgeBaseContributor,
      'communityModerator': instance.communityModerator,
      'specialtyBadges': instance.specialtyBadges,
      'lastBadgeEarned': instance.lastBadgeEarned?.toIso8601String(),
    };

ExpertAvailability _$ExpertAvailabilityFromJson(Map<String, dynamic> json) =>
    ExpertAvailability(
      expertId: json['expertId'] as String,
      weeklySchedule: (json['weeklySchedule'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      timeZones: (json['timeZones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      primaryTimeZone: json['primaryTimeZone'] as String,
      acceptsUrgentQuestions: json['acceptsUrgentQuestions'] as bool? ?? true,
      maxResponseTime: json['maxResponseTime'] == null
          ? const Duration(hours: 24)
          : Duration(microseconds: (json['maxResponseTime'] as num).toInt()),
      availabilityNotes: json['availabilityNotes'] as String?,
    );

Map<String, dynamic> _$ExpertAvailabilityToJson(ExpertAvailability instance) =>
    <String, dynamic>{
      'expertId': instance.expertId,
      'weeklySchedule': instance.weeklySchedule,
      'timeZones': instance.timeZones,
      'primaryTimeZone': instance.primaryTimeZone,
      'acceptsUrgentQuestions': instance.acceptsUrgentQuestions,
      'maxResponseTime': instance.maxResponseTime.inMicroseconds,
      'availabilityNotes': instance.availabilityNotes,
    };

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
  startTime: TimeSlot._timeOfDayFromJson(
    json['startTime'] as Map<String, dynamic>,
  ),
  endTime: TimeSlot._timeOfDayFromJson(json['endTime'] as Map<String, dynamic>),
  isAvailable: json['isAvailable'] as bool? ?? true,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'startTime': TimeSlot._timeOfDayToJson(instance.startTime),
  'endTime': TimeSlot._timeOfDayToJson(instance.endTime),
  'isAvailable': instance.isAvailable,
  'notes': instance.notes,
};
