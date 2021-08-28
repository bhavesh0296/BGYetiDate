
import CoreLocation
import YelpAPI

public class YelpSearchColleague {

    public let category: YelpCategory
    public private(set) var selectedBusiness: YLPBusiness?

    private var colleagueCoordinate: CLLocationCoordinate2D?
    private unowned let mediator: SearchColleagueMediating
    private var userCoordinate: CLLocationCoordinate2D?
    private var yelpClient: YLPClient

    private static let defaultQueryLimit = UInt(20)
    private static let defaultQuerySort = YLPSortType.bestMatched
    private var queryLimit = defaultQueryLimit
    private var querySort = defaultQuerySort

    public init(category: YelpCategory,
                mediator: SearchColleagueMediating) {

        self.category = category
        self.mediator = mediator
        self.yelpClient = YLPClient(apiKey: YelpAPIKey)
    }
}

extension YelpSearchColleague: SearchColleague {

    public func update(userCoordinate: CLLocationCoordinate2D) {
        self.userCoordinate = userCoordinate
        performSearch()
    }

    public func fellowColleague(_ colleague: SearchColleague, didSelect busniess: YLPBusiness) {
        colleagueCoordinate = CLLocationCoordinate2D(busniess.location.coordinate)
        queryLimit = queryLimit/2
        querySort = .distance
        performSearch()
    }

    public func reset() {
        colleagueCoordinate = nil
        queryLimit = YelpSearchColleague.defaultQueryLimit
        querySort = YelpSearchColleague.defaultQuerySort
        selectedBusiness = nil
        performSearch()
    }

    private func performSearch() {
        guard selectedBusiness == nil,
            let coordinate = colleagueCoordinate ?? userCoordinate else {
                return
        }

        let yelpCoordinate = YLPCoordinate(coordinate)
        let yelpQuery = YLPQuery(coordinate: yelpCoordinate)
        yelpQuery.categoryFilter = [category.rawValue]
        yelpQuery.limit = queryLimit
        yelpQuery.sort = querySort

        yelpClient.search(with: yelpQuery) { [weak self] (search, error) in
            guard let self = self else { return }
            guard let search = search else {
                self.mediator.searchColleague(self, searchFailed: error)
                return
            }
            var set: Set<BusinessMapViewModel> = []
            let businessMapViewModelList = search.businesses.map { (yelpBusiness) -> BusinessMapViewModel? in
                guard let coordinate = yelpBusiness.location.coordinate else {
                    return nil
                }

                return BusinessMapViewModel(business: yelpBusiness,
                                            coordinate: coordinate,
                                            primaryCategory: self.category) { [weak self] business in
                                                guard let self = self else { return }
                                                self.selectedBusiness = business
                                                self.mediator.searchColleague(self, didSelect: business)
                }
            }.compactMap { $0 }

            set = Set<BusinessMapViewModel>(businessMapViewModelList)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.mediator.searchColleague(self, didCreate: set)
            }
        }
    }


}
