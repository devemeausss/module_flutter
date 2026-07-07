part of 'template_list_bloc.dart';

class TemplateListState extends Equatable {
  final ListModel<TemplateListModel> TemplateListList;

  const TemplateListState({required this.TemplateListList});

  factory TemplateListState.empty() {
    return const TemplateListState(TemplateListList: ListModel());
  }

  TemplateListState copyWith({ListModel<TemplateListModel>? TemplateListList}) {
    return TemplateListState(
      TemplateListList: TemplateListList ?? this.TemplateListList,
    );
  }

  @override
  List<Object?> get props => [TemplateListList];
}
