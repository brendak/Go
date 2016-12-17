//
//  AppDelegate.swift
//  Go!
//
//  Created by Brenda Kaing on 12/9/16.
//  Copyright © 2016 Brenda Kaing. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class SweetMapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    //****************** MARK: Variables
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager:CLLocationManager = CLLocationManager()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myEvents: [Event] = []

    var tomorrow = Date()
    
    //****************** MARK: Fixture
    
    var entries: [Entry] = []
    let events = [["Food Market","Held every Saturday", "37.758228","-122.438026", "235 Eureka St, San Francisco, CA 94114 : 9AM - 4PM", "012/12/2017"],
                  ["Beer Fest", "The best beer in the west", "37.787569", "-122.436398", "2424 Pine St, San Francisco, CA 94115 : 2PM - 10PM", "12/12/2016"],
                  ["Car Show", "Semi Annual European Car Show: The best Porsches, Lamborghinis, and Ferraris in the West Coast. Typically hosts over two hundred cars coming from all over the state.", "37.783674", "-122.415487", "480 Eddy St, San Francisco, CA 94109 : 8AM - 4PM", "12/21/2016"],
                  ["Walking Tour", "Let's check out some museums", "37.790697", "-122.391765", "201 Spear St, San Francisco, CA 94105 : 8AM - 9AM", "12/21/2016"],
                  ["Walking Tour", "Waterfront Tour", "37.773409", "-122.510237", "787 La Playa St, San Francisco, CA 94121 : 10AM - 12PM", "12/28/2016"],
                  ["Golden Gate Tour", "Get some exercise and see nature in the city", "37.834488", "-122.478381", "670 Center Rd, Sausalito, CA 94965 : 10AM - 11AM", "12/28/2016"],
                  ["Berkeley Food Festival", "Come and enjoy some of the best food trucks in the nation", "37.842925", "-122.292726", "6250 Overland Ave, Emeryville, CA 94608 : 11AM - 7PM", "12/14/2016"],
                  ["Walking Tour", "South San Francisco's Best walking tour", "37.648502", "-122.428808", "El Camino, South San Francisco, CA 94080, CA 94121 : 11AM - 12PM", "12/21/2016"],
                  ["Basement Comedy Store", "The Victorian", "34.0015354", "-118.4855927", "2640 Main St Santa Monica, CA 90405: 7:30PM", "12/14/2016"],
                  ["Music Mondays", "Runaway Playa Vista", "33.977041", "-118.419495", "12746 W Jefferson Blvd, Playa Vista, California 90066: 5PM - 7PM", "12/15/2016"],
                  ["Lights On Display", "Lights On Display", "34.141388", "-118.4508257", "3901 Longview Valley Rd, Sherman Oaks: 5PM - 9PM", "12/13/2016"],
                  ["Free Admission", "LACMA", "34.0639367", "-118.361418", "5905 Wilshire Blvd, Los Angeles, CA 90036: 11AM - 5PM", "12/13/2016"],
                  ["Free Admission", "Autry Museum", "34.1486244", "-118.2834017", "4700 Western Heritage Way, Griffith Park, Los Angeles, CA 90027:11AM - 5PM", "12/13/2016"],
                  ["Liquid Intelligence: Cocktail Class", "The Mixing Room", "34.1113552", "-118.3746255", "900 W Olympic Blvd Los Angeles, CA 90015: 7PM - 9PM", "12/14/2016"],
                  ["The Steinbeck Fellows Readings", "Dr. Martin Luther King, Jr. Library ", "37.3355068" , "-121.8871875", "150 E San Fernando St, San Jose, CA: 7PM", "12/15/2016"],
                  ["Christmas in the Park", "Plaza de Cesar Chavez", "37.333157", "-121.892087", "Market Street, San Jose, CA: ALL DAY", "12/13/2016"],
                  ["On Models of Contemplation", "San Jose Institute of Contemporary Art", "37.327833", "-121.8861237", "560 S 1st St, San Jose, CA 95113: 10AM - 5PM", "12/14/2016"],
                  ["Trancers Film", "Cyberpunk Cinema", "37.745149" ,"-122.419963", "3223 Mission St., SF: 6PM", "12/13/2016"],
                  ["Shift Presents: “The 24 Hour War” Documentary", "Castro Theatre", "37.762033", "-122.434759", "429 Castro St., San Francisco, CA: 6PM", "12/13/2016"],
                  ["Witches' Brew", "Black Hammer Brewing", "37.780707", "-122.397015", "544 Bryant St., San Francisco, CA: 7PM", "12/13/2016"],
                  ["Free Bagel Monday", "Sour Flour", "37.751039" , "-122.409817", "La Victoria Bakery, 24th St. & Alabama St., SF  7AM", "12/13/2016"],
                  ["Free Bagel Monday", "Sour Flour", "37.751039" , "-122.409817", "La Victoria Bakery, 24th St. & Alabama St., SF  7AM", "12/18/2016"],
                  ["Free Admission", "San Francisco Botanical Garden", "37.766387" , "-122.467181", "1199 9th Avenue, San Francisco, CA 94122  7AM", "12/13/2016"],
                  ["Curry Without Worry", "UN Plaza", "37.7799561" , "-122.4162554", "Civic Center/UN Plaza at Hyde and Fulton, SF", "12/13/2016"],
                  ["Factory Tour & Guided Tasting", "Dandelion Chocolate", "37.7610279" , "-122.4239672", "740 Valencia St (at 18th), San Francisco, CA 94110", "12/13/2016"],
                  ["Live Jazz", "Cigar Bar", "37.7971573" , "-122.4055948", "850 Montgomery Street, San Francisco, CA", "12/13/2016"],
                  ["Live Jazz", "Cigar Bar", "37.7971573" , "-122.4055948", "850 Montgomery Street, San Francisco, CA", "12/14/2016"],
                  ["Live Jazz", "Cigar Bar", "37.7971573" , "-122.4055948", "850 Montgomery Street, San Francisco, CA", "12/15/2016"]]
   
    //****************** MARK: UI Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.determineCurrentLocation()
        mapView.delegate = self
        dateSetter()
        plotView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //****************** MARK: Fetch Core CoreData
    
    func fetchData() {
        let eventRequest = NSFetchRequest<Event>(entityName: "Event")
        do {
            let results = try managedObjectContext.fetch(eventRequest as! NSFetchRequest<NSFetchRequestResult>)
            myEvents = results as! [Event]
        } catch {
            print("\(error)")
        }
    }
    
    //****************** MARK: Table
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableView {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell")
//        return cell!
//    }
    
    //****************** MARK: Map View
    
    func plotView() {
        entries = []
        for event in events {
            let entry = Entry(title: event[0], detail: event[1], date: dateFormat(date: event[5]), coordinate: CLLocationCoordinate2D(latitude: Double(event[2])!, longitude: Double(event[3])!), address: event[4])
            let tomorrowTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)
            if entry.date >= tomorrow && entry.date <= tomorrowTomorrow! {
                entries.append(entry)
                print(entries)
            } else if sliderSlider.value == 0{
                if entry.date >= today {
                    entries.append(entry)
                }
            }
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(_ :entries)
        
        // Add user selected events
        fetchData()
        var myPins: [Entry] = []
        for event in myEvents {
            let entry = Entry(title: event.title!, detail: event.detail!, date: event.date! as Date, coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude), address: event.address!)
            myPins.append(entry) as? Event
        }
        mapView.addAnnotations(myPins) as? Event
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Entry"
        let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
        if annotation is Entry {
            annotationView.pinTintColor = .purple
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
        } else if annotation is Event {
            annotationView.pinTintColor = .red
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
        }
        else {
            return nil
        }
        let btn = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = btn
        let button = UIButton(type: .detailDisclosure)
        button.setImage(UIImage(named: "Go-1"), for: .normal)
        annotationView.leftCalloutAccessoryView = button
        return annotationView
    }
    
    //****************** MARK: Map View Action
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let event = view.annotation as! Entry
            let eventName = event.title
            let eventInfo = event.subtitle
            let ac = UIAlertController(title: eventName!, message: eventInfo!, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let event = view.annotation as! Entry
            let entry = NSEntityDescription.insertNewObject(forEntityName: "Event", into: managedObjectContext) as! Event
            entry.title = event.title
            entry.detail = event.subtitle
            entry.date = event.date as NSDate?
            entry.address = event.address
            entry.longitude = event.coordinate.longitude
            entry.latitude = event.coordinate.latitude
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                    print("Success")
                } catch {
                    print("\(error)")
                }
            }
            print("Left button clicked!")
        }
    }
    
    //****************** MARK: User Location
    
    func determineCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        mapView.setRegion(region, animated: true)
        // Drop a pin at user's Current Location
//        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
//        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
//        myAnnotation.title = "Current location"
//        mapView.addAnnotation(myAnnotation)
        mapView.showsUserLocation = true
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error \(error)")
    }
    
    //****************** MARK: Search Bar
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    //****************** MARK: Slider
    
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var sliderSlider: UISlider!
    let today = Date()
    
    
    @IBAction func dateSlider(_ sender: UISlider) {
        
        tomorrow = Calendar.current.date(byAdding: .day, value: Int(sliderSlider.value), to: today)!
        let roundedValue = round(sliderSlider.value / 1.0) * 1.0
        sliderSlider.value = roundedValue
        dateSetter()
        plotView()
    }
    
    // MARK: - Core Location Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func dateFormat (date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateFromString = dateFormatter.date(from: date)
        return dateFromString!
    }
    func dateSetter (){
        let formatter = DateFormatter()
        if sliderSlider.value != 0 {
            formatter.dateStyle = .medium
            lowerLabel.text = formatter.string(from: tomorrow)
        }
        else {
            formatter.dateFormat = "MMMM"
            lowerLabel.text = formatter.string(from: tomorrow)
        }
    }

}

