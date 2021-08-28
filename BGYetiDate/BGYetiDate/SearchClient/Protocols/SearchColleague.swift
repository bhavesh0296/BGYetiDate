
import CoreLocation.CLLocation
import YelpAPI

public protocol SearchColleague: class {

    var category: YelpCategory { get }
    var selectedBusiness: YLPBusiness? { get }

    func update(userCoordinate: CLLocationCoordinate2D)

    func fellowColleague(_ colleague: SearchColleague,
                         didSelect busniess: YLPBusiness)

    func reset()
}
