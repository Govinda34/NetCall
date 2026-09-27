class BillingCalculator {
  static Map<String,num> calculate({required String type,required double rate,required int start,required int end}) {
    var mins=end-start; if(mins<0) mins+=1440;
    final hours=mins/60.0;
    final days=type=='Per Day'?1.0:hours/8.0;
    final amount=type=='Per Minute'?mins*rate:type=='Per Hour'?hours*rate:days*rate;
    return {'minutes':mins,'hours':hours,'days':days,'amount':amount};
  }
}
