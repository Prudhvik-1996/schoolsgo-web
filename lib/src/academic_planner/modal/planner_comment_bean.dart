const String _jsonKeyPlannerCommentBeanCommenter = 'a';
const String _jsonKeyPlannerCommentBeanComment = 'c';
const String _jsonKeyPlannerCommentBeanDate = 'd';
class PlannerCommentBean {
/*
{
  "commenter": "Prudhvik",
  "comment": "Improve this",
  "date": "2023-01-01"
}
*/

  String? commenter;
  String? comment;
  String? date;
  Map<String, dynamic> __origJson = {};

  PlannerCommentBean({
    this.commenter,
    this.comment,
    this.date,
  });
  PlannerCommentBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    commenter = json[_jsonKeyPlannerCommentBeanCommenter]?.toString();
    comment = json[_jsonKeyPlannerCommentBeanComment]?.toString();
    date = json[_jsonKeyPlannerCommentBeanDate]?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[_jsonKeyPlannerCommentBeanCommenter] = commenter;
    data[_jsonKeyPlannerCommentBeanComment] = comment;
    data[_jsonKeyPlannerCommentBeanDate] = date;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

