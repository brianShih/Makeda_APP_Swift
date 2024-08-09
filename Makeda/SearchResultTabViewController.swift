/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Primary view controller used to display search results.
 */

import UIKit
import CoreLocation
import MapKit

class SearchResultTabViewController: UITableViewController {
    let debug = 0
    let fullSize = UIScreen.main.bounds.size
    private enum SegueID: String {
        case ToAddVC
        case showAll
    }
    
    private enum CellReuseID: String {
        case resultCell
    }
    
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
            //viewAllButton.isEnabled = places != nil
            if debug == 1 {
                print("places --> didSet")
            }
        }
    }
    
    private var SearchFuncInit = false
    
    var sel_name:String?
    var sel_phone:String?
    var sel_country:String?
    var sel_city:String?
    var sel_address:String?
    var sel_fb:String?
    var sel_web:String?
    var sel_bloggerIntro:String?
    var sel_opentime:String?
    var sel_note:String?
    var sel_score:String?
    
    var suggestionController: SuggestionsTabViewController!
    var searchController: UISearchController!

    @IBOutlet private var locationManager: LocationManager!
    private var locationManagerObserver: NSKeyValueObservation?
    
    private var foregroundRestorationObserver: NSObjectProtocol?
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
            if debug == 1 {
                print("localSearch:willSet:clean places")
            }
        }
    }
    
    private var boundingRegion: MKCoordinateRegion?
    
    override init(nibName: String?, bundle: Bundle?)
    {
        //super.init()
        super.init(nibName: nil, bundle: nil)
        searchFuncInit()
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 導覽列左邊按鈕
        let leftButton = UIBarButtonItem(title: "＜", style: .plain, target: self, action: #selector(SearchResultTabViewController.back))
        leftButton.tintColor = UIColor.white
        
        // 加到導覽列中
        self.navigationItem.leftBarButtonItem = leftButton
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        /*
         Search is presenting a view controller, and needs the presentation context to be defined by a controller in the
         presented view controller hierarchy.
         */
        definesPresentationContext = true
        tableView.register(SearchCompletionTableViewCell.self, forCellReuseIdentifier: SearchCompletionTableViewCell.reuseID)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
        self.navigationItem.title = "線上快速搜尋"
        //self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        if debug == 1 {
            print("search -- MKLocalSearchCompleter")
            print("search -- MKLocalSearchCompleter: ",suggestedCompletion.title)
        }
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        if let region = boundingRegion {
            searchRequest.region = region
        }
        
        // Use the network activity indicator as a hint to the user that a search is in progress.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard error == nil else {
                self?.displaySearchError(error)
                return
            }
            
            self?.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            self?.boundingRegion = response?.boundingRegion
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func searchFuncInit()
    {
        if SearchFuncInit { return }

        locationManager = LocationManager()
        
        suggestionController = SuggestionsTabViewController()
        suggestionController.tableView.delegate = self
        
        
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        searchController.searchBar.isUserInteractionEnabled = false
        searchController.searchBar.alpha = 0.5
        
        tableView.tableHeaderView = searchController.searchBar
        
        locationManagerObserver =
            locationManager.observe(\LocationManager.currentLocation) { [weak self] (_, _) in
                if let location = self!.locationManager.currentLocation {
                    // This sample only searches for nearby locations, defined by the device's location. Once the current location is
                    // determined, enable the search functionality.
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 12_000, 12_000)
                    self?.suggestionController.searchCompleter.region = region
                    self?.boundingRegion = region
                    
                    self?.searchController.searchBar.isUserInteractionEnabled = true
                    self?.searchController.searchBar.alpha = 1.0
                    
                    self?.tableView.reloadData()
                }
        }
        

        let name = NSNotification.Name.UIApplicationWillEnterForeground
        //UIApplication.willEnterForegroundNotification
        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [weak self] (_) in
            // Get a new location when returning from Settings to enable location services.
            self?.locationManager.requestLocation()
        })

        locationManager.requestLocation()
        SearchFuncInit = true
    }
    
    @objc func back()
    {
        self.navigationController!.popToRootViewController(animated: true)
    }
}

extension SearchResultTabViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard locationManager.currentLocation != nil else {

            return 1
        }
        return places?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard locationManager.currentLocation != nil else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = NSLocalizedString("啟動定位系統中...", comment: "Waiting for location table cell")
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.startAnimating()
            cell.accessoryView = spinner
            
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCompletionTableViewCell.reuseID, for: indexPath)

        if let mapItem = places?[indexPath.row] {

            if let name = mapItem.name
            {
                cell.textLabel?.text = name
            }
            if let phone = mapItem.phoneNumber
            {
                cell.textLabel?.text =  (cell.textLabel?.text)! + " |電話 " + phone
            }
            if let addr = mapItem.placemark.formattedAddress
            {
                cell.detailTextLabel?.text = addr
                if debug == 1 {
                    print("ADDR: ", addr)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard locationManager.currentLocation != nil else { return }
        
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            if debug == 1 {
                print("Press Index: ", indexPath.row)
            }
            search(for: suggestion)
        }
        else
        {
            if debug == 1 {
                print("else press.......")
            }
            
            
            if let mapItem = places?[indexPath.row] {
                if let nameStr = mapItem.name
                {
                    if debug == 1 {
                        print("Name: ", mapItem.name!)
                    }
                    sel_name = nameStr
                }
                else
                {
                    return
                }
                
                if let phoneStr = mapItem.phoneNumber
                {
                    if debug == 1 {
                        print("phoneNumber: ", mapItem.phoneNumber!)
                    }
                    sel_phone = phoneStr
                }
                else
                {
                    sel_phone = "待補充"
                }
                
                if let countryStr = mapItem.placemark.country
                {
                    if debug == 1 {
                        print("country: ", mapItem.placemark.country!)
                    }
                    sel_country = countryStr
                }
                else
                {
                    sel_country = "待補充"
                }
                
                if let cityStr = mapItem.placemark.subAdministrativeArea
                {
                    if debug == 1 {
                        print("city: ", mapItem.placemark.subAdministrativeArea!)
                    }
                    sel_city = cityStr
                }
                else
                {
                    sel_city = "待補充"
                }
                
                if let addressStr = mapItem.placemark.formattedAddress
                {
                    if debug == 1 {
                        print("address: ", mapItem.placemark.formattedAddress!)
                    }
                    sel_address = addressStr
                }
                else
                {
                    sel_address = "待補充"
                }
                
                if let urlString = mapItem.url?.absoluteString
                {
                    if debug == 1 {
                        print("url: ", urlString)
                    }
                    if urlString.hasPrefix("https://www.facebook")
                    {
                        sel_fb = urlString
                        sel_web = "待補充"
                    }
                    else
                    {
                        sel_fb = "待補充"
                        sel_web = urlString
                    }
                }
                else
                {
                    sel_fb = "待補充"
                    sel_web = "待補充"
                }
                sel_note = "#食 #衣 #住 #行"
                sel_score = "待補充"
                sel_bloggerIntro = "待補充"
                sel_opentime = " "
                if debug == 1 {
                    print("trigger setup data start")
                }
                saveSearchData(name: sel_name!, phone: sel_phone!, country: sel_country!, city: sel_city!, address: sel_address!, fburl: sel_fb!, weburl: sel_web!, bloggerIntroUrl: sel_bloggerIntro!, opentime: sel_opentime!, note: sel_note!, score: sel_score!)
                if debug == 1 {
                    print("trigger setup data done")
                }

                back()
                

            }
            else
            {
                if debug == 1 {
                    print("get places fail,, it's null")
                }
            }
            //textFieldUpdate(name:String, phone:String, country:String, city:String, address:String, weburl:String, bloggerIntroUrl:String)

        }
    }
    
    //func saveSearchData(ppItems:SelPP_Items)
    func saveSearchData(name:String, phone:String, country:String, city:String, address:String, fburl:String, weburl:String, bloggerIntroUrl:String, opentime:String, note:String, score:String)
    {
        let updated = 1
        let myUserDefaults = UserDefaults.standard
        if let mapItemsUpdated = myUserDefaults.object(forKey: "mapItemsDataUpdate") as? Int {
            if debug == 1 {
                print("SearchResultTabViewController: mapItemsUpdated flag check: ",mapItemsUpdated)
            }
            if mapItemsUpdated == 0
            {
                if debug == 1 {
                    print("saveSearchData: save ppItems")
                }
                myUserDefaults.set(name, forKey: "ppItemsName")
                myUserDefaults.set(phone, forKey: "ppItemsPhone")
                myUserDefaults.set(country, forKey: "ppItemsCountry")
                myUserDefaults.set(city, forKey: "ppItemsCity")
                myUserDefaults.set(address, forKey: "ppItemsAddress")
                myUserDefaults.set(fburl, forKey: "ppItemsFBUrl")
                myUserDefaults.set(weburl, forKey: "ppItemsWebUrl")
                myUserDefaults.set(bloggerIntroUrl, forKey: "ppItemsBloggerIntro")
                myUserDefaults.set(opentime, forKey: "ppItemsOpentime")
                myUserDefaults.set(note, forKey: "ppItemsNote")
                myUserDefaults.set(score, forKey: "ppItemsScore")
                if debug == 1 {
                    print("saveSearchData: save ppItems done....")
                }
                myUserDefaults.set(updated, forKey: "mapItemsDataUpdate")
                if debug == 1 {
                    print("saveSearchData: save mapItemsDataUpdate done....")
                }
                myUserDefaults.synchronize()
            }
        }
    }
}

extension SearchResultTabViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        //searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        //searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        //searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        //searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
        search(for: searchBar.text)
    }
}

private class SearchCompletionTableViewCell: UITableViewCell {
    
    static let reuseID = "SearchCompletionTableViewCellReuseID"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
