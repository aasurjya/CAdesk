import 'package:flutter/material.dart';

/// Immutable model for an LLP partner (designated or regular).
@immutable
class LLPPartner {
  const LLPPartner({
    required this.name,
    required this.din,
    required this.email,
    required this.isDesignated,
  });

  final String name;
  final String din;
  final String email;
  final bool isDesignated;

  LLPPartner copyWith({
    String? name,
    String? din,
    String? email,
    bool? isDesignated,
  }) {
    return LLPPartner(
      name: name ?? this.name,
      din: din ?? this.din,
      email: email ?? this.email,
      isDesignated: isDesignated ?? this.isDesignated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LLPPartner &&
          runtimeType == other.runtimeType &&
          din == other.din &&
          name == other.name &&
          isDesignated == other.isDesignated;

  @override
  int get hashCode => Object.hash(din, name, isDesignated);

  @override
  String toString() =>
      'LLPPartner(name: $name, din: $din, '
      'designated: $isDesignated)';
}

/// Immutable model representing a Limited Liability Partnership entity.
@immutable
class LLPEntity {
  const LLPEntity({
    required this.id,
    required this.llpName,
    required this.llpin,
    required this.incorporationDate,
    required this.turnover,
    required this.capitalContribution,
    required this.isAuditRequired,
    required this.designatedPartners,
    required this.registeredOffice,
    required this.rocJurisdiction,
  });

  final String id;
  final String llpName;
  final String llpin;
  final DateTime incorporationDate;
  final double turnover;
  final double capitalContribution;

  /// True if turnover > 40 lakh or contribution > 25 lakh.
  final bool isAuditRequired;
  final List<LLPPartner> designatedPartners;
  final String registeredOffice;
  final String rocJurisdiction;

  /// Count of designated partners.
  int get designatedPartnerCount =>
      designatedPartners.where((p) => p.isDesignated).length;

  /// Total partner count.
  int get totalPartnerCount => designatedPartners.length;

  /// Returns a new [LLPEntity] with the given fields replaced.
  LLPEntity copyWith({
    String? id,
    String? llpName,
    String? llpin,
    DateTime? incorporationDate,
    double? turnover,
    double? capitalContribution,
    bool? isAuditRequired,
    List<LLPPartner>? designatedPartners,
    String? registeredOffice,
    String? rocJurisdiction,
  }) {
    return LLPEntity(
      id: id ?? this.id,
      llpName: llpName ?? this.llpName,
      llpin: llpin ?? this.llpin,
      incorporationDate: incorporationDate ?? this.incorporationDate,
      turnover: turnover ?? this.turnover,
      capitalContribution: capitalContribution ?? this.capitalContribution,
      isAuditRequired: isAuditRequired ?? this.isAuditRequired,
      designatedPartners: designatedPartners ?? this.designatedPartners,
      registeredOffice: registeredOffice ?? this.registeredOffice,
      rocJurisdiction: rocJurisdiction ?? this.rocJurisdiction,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LLPEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          llpName == other.llpName &&
          llpin == other.llpin &&
          turnover == other.turnover &&
          capitalContribution == other.capitalContribution &&
          isAuditRequired == other.isAuditRequired;

  @override
  int get hashCode => Object.hash(
        id,
        llpName,
        llpin,
        turnover,
        capitalContribution,
        isAuditRequired,
      );

  @override
  String toString() =>
      'LLPEntity(name: $llpName, llpin: $llpin, '
      'audit: $isAuditRequired)';
}
