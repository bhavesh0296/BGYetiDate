
import YelpAPI

public protocol SearchColleagueMediating: class {

    func searchColleague(_ searchColleague: SearchColleague,
                         didSelect business: YLPBusiness)

    func searchColleague(_ searchColleague: SearchColleague,
                         didCreate viewModels: Set<BusinessMapViewModel>)

    func searchColleague(_ searchColleague: SearchColleague,
                         searchFailed error: Error?)
}
