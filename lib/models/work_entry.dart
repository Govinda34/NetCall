class WorkEntry {
  final int? id; final String date,paymentType,status; final double rate,amount,totalHours; final int totalMinutes;
  WorkEntry({this.id,required this.date,required this.paymentType,required this.rate,required this.amount,required this.totalHours,required this.totalMinutes,this.status='Unpaid'});
  Map<String,Object?> toMap()=>{'id':id,'date':date,'payment_type':paymentType,'rate':rate,'amount':amount,'total_hours':totalHours,'total_minutes':totalMinutes,'status':status};
}
