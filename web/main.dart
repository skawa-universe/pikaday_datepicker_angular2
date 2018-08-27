import 'package:angular/angular.dart';
import 'package:pikaday_datepicker_angular2/pikaday_datepicker_angular2.dart';
import 'main.template.dart' as ng;

void main() {
  runApp(ng.AppComponentNgFactory);
}

// example app to showcase the PikadayComponent.
@Component(
    selector: 'showcase-pikadate-component',
    template: '''<pikaday [(day)]="selectedDay" format="DD-MM-YYYY"
                          firstDay="1" minDate="2010-1-1" maxDate="2025-12-31"
                          placeholder="select a day">
                 </pikaday>
                 <div>selectedDay: {{selectedDay}}</div>''',
    directives: [PikadayComponent])
class AppComponent {
  DateTime selectedDay = DateTime(2015, 2, 1);
}