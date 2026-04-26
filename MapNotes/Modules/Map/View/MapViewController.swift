import UIKit
import SnapKit
import MapKit

final class MapViewController: UIViewController {
    private var markerGlyphCache: [OverpassCategory: UIImage] = [:]

    private let presenter: MapViewOutput
    private let mapView = MKMapView(frame: .zero)
    private var placesById: [String: Place] = [:]

    private let filtersButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = .filterButtonTitle
        config.image = .filterIcon
        config.imagePadding = .Spx1_5
        return UIButton(configuration: config)
    }()

    private let centerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = .centerButtonTitle
        config.image = .centerOnUserIcon
        config.imagePadding = .Spx1_5
        return UIButton(configuration: config)
    }()

    private let searchEntryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemFill
        button.layer.cornerRadius = .Spx3
        button.tintColor = .secondaryLabel
        button.setTitle(.mapSearchPlaceholder, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setImage(.searchIcon, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        return button
    }()

    private let searchEntryButtonBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .Spx4 + .Spx2
        view.backgroundColor = .systemBackground
        return view
    }()

    init(presenter: MapViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = .mapNavigationTitle
        view.backgroundColor = .systemBackground

        setupUI()
        presenter.viewDidLoad()
    }
}

extension MapViewController: MapViewInput {
    func configure(_ viewModel: MapViewModel) {
        searchEntryButton.setTitle(viewModel.searchPlaceholder, for: .normal)
    }

    func moveCamera(to location: CLLocationCoordinate2D, zoom: Float) {
        let spanDelta = max(0.001, 120 / pow(2.0, Double(zoom)))
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        )
        mapView.setRegion(region, animated: true)
    }

    func showPlaces(_ places: [Place]) {
        let existing = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existing)
        placesById.removeAll()

        for place in places {
            placesById[place.id] = place
            let annotation = PlaceAnnotation(place: place)
            mapView.addAnnotation(annotation)
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: .errorAlertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .commonOK, style: .default))
        present(alert, animated: true)
    }
}

private extension MapViewController {
    func markerGlyph(for category: OverpassCategory) -> UIImage {
        if let cached = markerGlyphCache[category] { return cached }
        let image = category.mapPinImage(pointSize: .Spx4 + .Spx0_5)
        markerGlyphCache[category] = image
        return image
    }

    func setupUI() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mapView.delegate = self
        mapView.showsUserLocation = true

        view.addSubview(filtersButton)
        view.addSubview(centerButton)
        view.addSubview(searchEntryButtonBackground)
        searchEntryButtonBackground.addSubview(searchEntryButton)

        filtersButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.Spx3)
            make.trailing.equalToSuperview().inset(CGFloat.Spx3)
        }

        centerButton.snp.makeConstraints { make in
            make.top.equalTo(filtersButton.snp.bottom).offset(CGFloat.Spx2)
            make.trailing.equalTo(filtersButton)
        }

        searchEntryButtonBackground.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
        }

        searchEntryButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(CGFloat.Spx3)
            make.leading.trailing.equalToSuperview().inset(CGFloat.Spx3)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.Spx3)
            make.height.equalTo(CGFloat.Spx8 + CGFloat.Spx4)
        }

        filtersButton.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)
        centerButton.addTarget(self, action: #selector(centerTapped), for: .touchUpInside)
        searchEntryButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
    }

    @objc func filtersTapped() {
        presenter.didTapFilters()
    }

    @objc func centerTapped() {
        presenter.didTapCenterOnUser()
    }

    @objc func searchTapped() {
        presenter.didTapSearch()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region
        let halfLat = region.span.latitudeDelta / 2.0
        let halfLon = region.span.longitudeDelta / 2.0
        let bounds = GeoBounds(
            south: region.center.latitude - halfLat,
            west: region.center.longitude - halfLon,
            north: region.center.latitude + halfLat,
            east: region.center.longitude + halfLon
        )
        presenter.didChangeVisibleRegion(bounds)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }

        let marker = (mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationReuseID.placeMarker) as? MKMarkerAnnotationView)
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: AnnotationReuseID.placeMarker)
        marker.annotation = annotation
        marker.canShowCallout = false
        marker.markerTintColor = placeAnnotation.place.mapCategory.mapPinTintColor
        marker.glyphImage = markerGlyph(for: placeAnnotation.place.mapCategory)
        return marker
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
        presenter.didSelectPlace(placeAnnotation.place)
        mapView.deselectAnnotation(placeAnnotation, animated: false)
    }
}

private enum AnnotationReuseID {
    static let placeMarker = "MapPlaceMarkerAnnotationView"
}

private extension String {
    static let mapNavigationTitle = "Map Notes"
    static let mapSearchPlaceholder = "Поиск места"
    static let filterButtonTitle = "Фильтр"
    static let centerButtonTitle = "Я"
    static let errorAlertTitle = "Ошибка"
    static let commonOK = "OK"
}

private extension UIEdgeInsets {
    static let mapSearchContentInsets = UIEdgeInsets(top: .Spx3, left: .Spx3 + .Spx0_5, bottom: .Spx3, right: .Spx3 + .Spx0_5)
}
