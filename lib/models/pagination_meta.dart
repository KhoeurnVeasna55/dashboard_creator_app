
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final String sortBy;
  final String order;
  final bool hasPrev;
  final bool hasNext;
  final int? prevPage;
  final int? nextPage;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.sortBy,
    required this.order,
    required this.hasPrev,
    required this.hasNext,
    this.prevPage,
    this.nextPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> j) => PaginationMeta(
        page: j["page"],
        limit: j["limit"],
        total: j["total"],
        pages: j["pages"],
        sortBy: j["sortBy"],
        order: j["order"],
        hasPrev: j["hasPrev"],
        hasNext: j["hasNext"],
        prevPage: j["prevPage"],
        nextPage: j["nextPage"],
      );
}