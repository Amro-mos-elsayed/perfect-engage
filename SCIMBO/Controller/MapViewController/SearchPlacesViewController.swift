//
//  SearchPlacesViewController.swift
//  mapkitDemo
//
//  Created by Casperon Technologies Pvt Ltd on 10/06/17.
//  Copyright © 2017 Casperon Technologies Pvt Ltd. All rights reserved.
//

import UIKit
import MapKit
protocol coordinate : class {
    func selected(place:CLLocationCoordinate2D)
    func info(array:[MKLocalSearchCompletion])
    func search(text:String)
}
class SearchPlacesViewController: UIViewController {
    weak var delegate :coordinate?
    var location : CLLocationCoordinate2D!
  
    @IBOutlet weak var search_TableView: UITableView!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var text_v=""
    override func viewDidLoad() {
        super.viewDidLoad()
       //search_Bar.delegate = self
       searchCompleter.delegate = self
        // Do any additional setup after loading the view.
    }

    @IBAction func backView(_ sender: UIButton) {
        self.navigationController?.pop(animated:true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
//    extension SearchPlacesViewController: UISearchBarDelegate {
//        
//        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
//            searchCompleter.queryFragment = searchText
//            self.text_v = searchText
//            print(searchText)
//        }
//        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//            if(self.searchResults.count > 0){
//                self.delegate?.info(array: self.searchResults)
//                self.delegate?.search(text: self.text_v)
//                self.pop(animated: true)
//            }
//            
//
//        }
//    }

extension SearchPlacesViewController:UITextFieldDelegate
{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchCompleter.queryFragment = textField.text!
        self.text_v = textField.text!
        print("current char set : ", textField.text!)
        self.delegate?.search(text: self.text_v)
        return true;
        
    }
    
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     self.delegate?.search(text: textField.text!)
             self.delegate?.info(array: self.searchResults)
            self.navigationController?.pop(animated:true)
        
        return true
    }
}
    extension SearchPlacesViewController: MKLocalSearchCompleterDelegate {
        
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            searchResults = completer.results
            delegate?.info(array:searchResults)
            search_TableView.reloadData()
        }
        
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            // handle error
        }
    }
    
    extension SearchPlacesViewController: UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            
            return 1
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return searchResults.count

        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            _ = searchResults[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//            cell.textLabel?.text = searchResult.title
//            cell.detailTextLabel?.text = searchResult.subtitle
            return cell
            
        }
    }
    
    extension SearchPlacesViewController: UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            _ = self.storyboard?.instantiateViewController(withIdentifier:"map") as! MapViewViewController
            
            let completion = searchResults[indexPath.row]
            
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                _ = response?.mapItems[0].placemark.coordinate
                self.location = response?.mapItems[0].placemark.coordinate
                print(String(describing: self.location))
                
                
            }
            
            
            
        }

}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


