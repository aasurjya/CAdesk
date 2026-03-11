/// ITR form types as defined by the Indian Income Tax Department.
enum ItrType {
  itr1(
    label: 'ITR-1',
    description: 'Sahaj - Salary, one house property, other sources (up to 50L)',
  ),
  itr2(
    label: 'ITR-2',
    description: 'Individuals/HUFs not having income from business or profession',
  ),
  itr3(
    label: 'ITR-3',
    description: 'Individuals/HUFs having income from business or profession',
  ),
  itr4(
    label: 'ITR-4',
    description: 'Sugam - Presumptive income from business or profession',
  ),
  itr5(
    label: 'ITR-5',
    description: 'Firms, AOPs, BOIs, LLPs, and similar entities',
  ),
  itr6(
    label: 'ITR-6',
    description: 'Companies other than those claiming exemption under section 11',
  ),
  itr7(
    label: 'ITR-7',
    description: 'Trusts, political parties, institutions, and colleges',
  );

  const ItrType({required this.label, required this.description});

  final String label;
  final String description;
}
