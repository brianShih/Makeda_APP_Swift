

import UIKit
import MapKit

class SuggestionsTabViewController: UITableViewController {
    let debug = 0
    
    let searchCompleter = MKLocalSearchCompleter()
    var completerResults: [MKLocalSearchCompletion]?
    
    convenience init() {
        //self.init(style: .plain)
        self.init(style: .grouped)
        searchCompleter.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SuggestedCompletionTableViewCell.self, forCellReuseIdentifier: SuggestedCompletionTableViewCell.reuseID)
    }
}

extension SuggestionsTabViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    /// - Tag: HighlightFragment
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.debug == 1 {
            print("SuggestionsTabViewController- tableView: cellForRowAt")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedCompletionTableViewCell.reuseID, for: indexPath)
        
        if let suggestion = completerResults?[indexPath.row] {
            // Each suggestion is a MKLocalSearchCompletion with a title, subtitle, and ranges describing what part of the title
            // and subtitle matched the current query string. The ranges can be used to apply helpful highlighting of the text in
            // the completion suggestion that matches the current query fragment.
            cell.textLabel?.attributedText = createHighlightedString(text: suggestion.title, rangeValues: suggestion.titleHighlightRanges)
            cell.detailTextLabel?.attributedText = createHighlightedString(text: suggestion.subtitle, rangeValues: suggestion.subtitleHighlightRanges)
        }
        
        return cell
    }
    
    private func createHighlightedString(text: String, rangeValues: [NSValue]) -> NSAttributedString {
        if self.debug == 1 {
            print("SuggestionsTabViewController- createHighlightedString")
        }
        let attributes = [NSAttributedString.Key.backgroundColor: UIColor.yellow ]
        let highlightedString = NSMutableAttributedString(string: text)

        // Each `NSValue` wraps an `NSRange` that can be used as a style attribute's range with `NSAttributedString`.
        let ranges = rangeValues.map { $0.rangeValue }
        ranges.forEach { (range) in
            highlightedString.addAttributes(attributes, range: range)
        }
        
        return highlightedString
    }
}

extension SuggestionsTabViewController: MKLocalSearchCompleterDelegate {
    
    /// - Tag: QueryResults
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // As the user types, new completion suggestions are continuously returned to this method.
        // Overwrite the existing results, and then refresh the UI with the new results.
        if self.debug == 1 {
            print("SuggestionsTabViewController -- completerDidUpdateResults")
        }
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if self.debug == 1 {
            print("SuggestionsTabViewController -- completer")
            // Handle any errors returned from MKLocalSearchCompleter.
            if let error = error as NSError? {
                print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription)")
            }
        }
    }
}

extension SuggestionsTabViewController: UISearchResultsUpdating {
    
    /// - Tag: UpdateQuery
    func updateSearchResults(for searchController: UISearchController) {
        if self.debug == 1 {
            print("SuggestionsTabViewController -- updateSearchResults")
            // Ask `MKLocalSearchCompleter` for new completion suggestions based on the change in the text entered in `UISearchBar`.
            print("searchBar.TEXT: ", searchController.searchBar.text!)
        }
        searchCompleter.queryFragment = searchController.searchBar.text ?? ""
        if self.debug == 1 {
            print("SuggestionsTabViewController -- updateSearchResults -- done")
        }
    }
}

private class SuggestedCompletionTableViewCell: UITableViewCell {
    
    static let reuseID = "SuggestedCompletionTableViewCellReuseID"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
