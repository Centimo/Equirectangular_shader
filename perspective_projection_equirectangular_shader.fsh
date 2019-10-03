varying highp vec2 qt_TexCoord0;
uniform vec2 resolution;
uniform vec2 currentPosition;
uniform int wheelPosition;
uniform sampler2D source;


#define M_PI 3.1415926535897932384626433832795


mat3 makeRotationMatrix(float phi)
{
    return mat3(
          1.0, 0.0,      0.0,
          0.0, cos(phi), -sin(phi),
          0.0, sin(phi), cos(phi)
    );
}

bool find_intersection_point(vec3 ray_source_point, vec3 lens_point, float radius, inout vec3 result)
{
  vec3 direction_vector =  lens_point - ray_source_point;
  float a_coefficient = dot(direction_vector, direction_vector);
  float b_coefficient = 2.0 * dot(direction_vector, ray_source_point);
  float c_coefficient = dot(ray_source_point, ray_source_point) - radius * radius;

  float discriminant = b_coefficient*b_coefficient - 4.0*a_coefficient*c_coefficient;

  if (discriminant < 0.0)
  {
    return false;
  }

  vec2 roots = vec2((-b_coefficient - sqrt(discriminant))/(2.0*a_coefficient),
                    (-b_coefficient + sqrt(discriminant))/(2.0*a_coefficient));

  float root = max(roots.x, roots.y);
  if (root > 1.0)
  {
    result = ray_source_point + direction_vector*root;
    return true;
  }
  else
  {
    return false;
  }
}

vec3 get_perpendicular(vec3 normal, float radius)
{
  vec3 result = vec3(0.0, 0.0, 0.0);

  if (normal.x == 0.0 && normal.y == 0.0)
  {
    result.x = radius / sqrt(2.0);
    result.y = result.x;
  }
  else if (normal.x == 0.0)
  {
    result.y = 0.0;
    result.x = radius;
  }
  else
  {
    result.y =  normal.x * normal.x * radius * radius / (normal.x * normal.x + normal.y * normal.y);
    result.x = - normal.y * result.y / normal.x;
  }

  return result;
}

void main()
{
    float shpere_radius = 2.0;
    float z_buffer = 2.0;
    float lens_radius = log(exp(0.3*float(wheelPosition) ) + 1.0);
    float tetha =  currentPosition.y * M_PI;
    float phi = -currentPosition.x * M_PI * 2.0;

    vec3 uv = vec3((gl_FragCoord.xy/resolution.xy - 0.5), 0.0);


    vec3 ray_source_point = vec3(-z_buffer * sin(tetha) * cos(phi),
                                 -z_buffer * sin(tetha) * sin(phi),
                                 -z_buffer * cos(tetha));

    vec3 first_lens_direction_vector = get_perpendicular(ray_source_point, lens_radius);
    if (mod(phi, 2.0*M_PI) < M_PI/2.0 || mod(phi, 2.0*M_PI) > 3.0 * M_PI/2.0)
    {
      // rotate on M_PI
      first_lens_direction_vector *= -1.0;
    }

    vec3 second_lens_direction_vector = cross(first_lens_direction_vector, ray_source_point);

    first_lens_direction_vector = normalize(first_lens_direction_vector) / lens_radius * resolution.x / resolution.y;
    second_lens_direction_vector = normalize(second_lens_direction_vector) / lens_radius;
    uv = uv.x * first_lens_direction_vector + uv.y * second_lens_direction_vector;

    vec3 itersection_point;
    bool is_exist = find_intersection_point(ray_source_point, uv, shpere_radius, itersection_point);
    if (!is_exist)
    {
      gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
      return;
    }

    vec2 point = vec2(atan(itersection_point.y, itersection_point.x)/M_PI/2.0,
                      acos(itersection_point.z / shpere_radius)/M_PI);

    vec3 col = texture2D(source, vec2(mod(point.x, 1.0), point.y)).rgb;
    gl_FragColor = vec4(col, 1.0);
}
